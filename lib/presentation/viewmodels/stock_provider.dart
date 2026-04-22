import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:riverpod/legacy.dart';
import 'package:stock_wise/data/models/product_model.dart';
import 'package:stock_wise/data/repository/stock_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/notifications/notifications_service.dart';
import 'auth_provider.dart';


final stockProvider = StateNotifierProvider<StockNotifier, List<ProductModel>>((ref){

  final user = ref.watch(authStateProvider).value;
  final repository = StockRepository();
  final householdId = user?.householdId ?? '';
  return StockNotifier(repository, householdId: householdId);



});
class StockNotifier extends StateNotifier<List<ProductModel>> {
  final StockRepository _repository;
  final String householdId;
  String _searchQuery = '';
  String _selectedCategory = 'Tout';
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  StockNotifier(this._repository, {required this.householdId}) : super([]) {
    if (householdId.isNotEmpty) {
      _init();
    }
  }

  //get les produits , afficher les ajoutés récemment en premier

  Future<void> _init() async {
    await loadProducts();
    _checkExpirations();
    _listenToSync();
  }
  Future<void> loadProducts() async {
    if (householdId.isEmpty) return;
    try {
      final products = await _repository.getAllProducts(householdId);

      products.sort((a, b) => b.updateAt.compareTo(a.updateAt));
      state = products;
    } catch (e) {
      debugPrint('[StockNotifier] loadProducts error: $e');
    }
  }
  StreamSubscription? _syncSubscription;

  //ecoute firebase , recharge hive une fois firebase se recharge
  void _listenToSync() {
    _syncSubscription?.cancel();

    _syncSubscription = _repository.syncFromFirestore(householdId).listen((_) {
      debugPrint('[StockNotifier] Sync reçu de Firestore, rechargement...');
      loadProducts();
    });
  }
  @override
  void dispose() {
    _syncSubscription?.cancel();
    super.dispose();
  }

  Future<void> addOrUpdateProduct(ProductModel product) async {
    try {
      await _repository.saveProducts(product);

      final index = state.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        state = [
          for (int i = 0; i < state.length; i++)
            if (i == index) product else state[i]
        ];
      } else {
        state = [product, ...state];
      }

    } catch (e) {
      debugPrint('[StockNotifier] addOrUpdateProduct error: $e');
    }
  }

  Future<void> removeProduct(String id) async {
    try {
      state = state.where((p) => p.id != id).toList();

      await _repository.deleteProduct(id);
    } catch (e) {
      debugPrint('[StockNotifier] removeProduct error: $e');
      await loadProducts();
    }
  }

  //recheche
  void updateSearchQuery(String query){
    _searchQuery = query.toLowerCase().trim();
    state = [...state];
  }
  //categorie selectionné
  void updateCategory(String category){
      _selectedCategory = category;
    state = [...state];
  }



  //mouvement de stock

  //Consommer
  Future<void> consumeOne(ProductModel product) async {
    if (product.quantity > 0) {
      final updated = product.copyWith(
        quantity: product.quantity - 1,
        updateAt: DateTime.now(),
      );

      await addOrUpdateProduct(updated);

      if (updated.isCritical) {
        NotificationService.showNotification(
          id: updated.id.hashCode,
          title: '⚠️ Stock Critique !',
          body: 'Le produit "${updated.name}" est presque épuisé.',
        );
      }
    }
  }

  // ajouter de quantité
  Future<void> incrementOne(ProductModel product) async {

      final updated = product.copyWith(
        quantity : product.quantity + 1,
        updateAt : DateTime.now(),
      );
      await addOrUpdateProduct(updated);

  }
  Future<void> consumeAmount(ProductModel product, [double amount = 1.0]) async {
    if (product.quantity > 0) {
      final double newQuantity = (product.quantity - amount).clamp(0.0, 99999.0);

      final updated = product.copyWith(
        quantity: newQuantity,
        updateAt: DateTime.now(),
      );

      await addOrUpdateProduct(updated);

      if (updated.isCritical || updated.quantity == 0) {
        NotificationService.showNotification(
          id: updated.id.hashCode + DateTime.now().millisecond,
          title: updated.quantity == 0 ? ' ❌ Rupture de Stock !' : '⚠️ Stock Critique !',
          body: 'Le produit "${updated.name}" doit être racheté.Il ne reste que ${updated.quantity.toInt()} ${updated.unity}',
        );
      }
    }
  }


  void _checkExpirations() {
    for (final p in state) {
      if (p.isExpired) {
        NotificationService.showNotification(
          id: p.id.hashCode + 10,
          title: '❌ Produit Périmé',
          body: '"${p.name}" a dépassé sa date de consommation.',
        );
      } else if (p.isExpiringSoon) {
        NotificationService.showNotification(
          id: p.id.hashCode + 20,
          title: '🕐 Expire bientôt',
          body: '"${p.name}" doit être consommé rapidement.',
        );
      }
    }
  }

  //Valider l'achat
  Future<void> validateAllChecked() async {
    //  récupère uniquement ce qui est coché
    final checked = shoppingList.where((p) => p.isChecked).toList();

    for (final p in checked) {


      double nouvelleQuantite = p.quantity + p.idealQuantity;


      String nouveauStatus = (p.location == ProductLocation.define || p.location.isEmpty)
          ? StockStatus.pending
          : StockStatus.active;


      final updated = p.copyWith(
        quantity: nouvelleQuantite,
        status: nouveauStatus,
        isChecked: false,
        updateAt: DateTime.now(),
      );
      await _repository.saveProducts(updated);


    }

    await loadProducts();
  }

//ajouter un produit via shoppingListe , la condition se pose si un produit existe déjà dans stock
  Future<void> addNewProductToShoppingList(String name, double price) async {
    final normalizedName = name.toLowerCase().trim();
    final existingIndex = state.indexWhere(
            (p) => p.name.toLowerCase().trim() == normalizedName
    );

    if (existingIndex != -1) {

      final existingProduct = state[existingIndex];

      final updatedProduct = existingProduct.copyWith(
        price: price,
        isChecked: true,
        updateAt: DateTime.now(),
      );

      await addOrUpdateProduct(updatedProduct);
    } else {
      final newProduct = ProductModel(
        id: DateTime.now().toString(),
        name: name,
        price: price,
        category: 'Autre',
        location: 'A définir',
        quantity: 0,
        threshold: 1,
        idealQuantity: 1,
        unity: 'pcs',
        updateAt: DateTime.now(),
        isChecked: true,
        status: 'active',
        householdId: householdId,
      );

      await addOrUpdateProduct(newProduct);
    }
  }

  //ranger un produit : si il vient d'etre ajouter dans shoppingliste mais n'existe pas dans stock
  Future<void> markAsRanged(ProductModel product) async {
    final updated = product.copyWith(
      status:   'active',
      updateAt: DateTime.now(),
    );
    await addOrUpdateProduct(updated);
  }

  //supprimer les produits périmés
  Future<void> clearAllExpired() async {
    final expiredOnes = state.where((p) => p.isExpired).toList();

    for (final product in expiredOnes) {
      await _repository.deleteProduct(product.id);
    }

    await loadProducts();
  }



  //Liste de course : produits en dessous du seuil
 List<ProductModel> get shoppingList =>
     state.where((p) => p.isCritical).toList();

  //produit acheté mais pas encore rangé
  List<ProductModel> get pendingProducts =>
      state.where((p) => p.status == 'pending').toList();

  // Liste des produits qui s'expirent bientôt
  List<ProductModel> get expiringSoonList {
      final list =  state.where((p) => p.expiryDate != null && p.isExpiringSoon).toList();
      list.sort((a, b) => a.expiryDate!.compareTo(b.expiryDate!));
      return list;

  }

 //action ou on coche un produit dans l'achat de shoppingList
  Future<void> toggleCheck(ProductModel product) async {
    final updated = product.copyWith(isChecked: !product.isChecked);
    await addOrUpdateProduct(updated);
  }


  //valeur totale des stocks présents
 double get totalStockValue =>
     state.fold(0.0,(total,item) => total +(item.price * item.quantity));

  //valeur de ce qu'il coche : les produits achetés dans shoopingList
  double get checkedShoppingList {
    return shoppingList
        .where((p) => p.isChecked)
        .fold(0.0, (total, item) {


      return total + (item.price * item.idealQuantity);
    });
  }

  //valeur des stocks seulement dans le shoopingList meme pas cochés
 double get estimatedShoppingTotal {
   return shoppingList.fold(0.0, (total,item) => total +(item.price * item.idealQuantity));

 }
  double get dashboardExpenses => checkedShoppingList;
  double get monthlyExpenses {
    final now = DateTime.now();
    return state.where((p) =>
    p.updateAt.month == now.month &&
        p.updateAt.year == now.year &&
        p.quantity > 0
    ).fold(0.0, (total, item) {
      return total + (item.price * item.idealQuantity);
    });
  }


//dépenses des 6mois derniers pour l'affichage du graphe
  List<double> get last6MonthsExpenses {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final target = DateTime(now.year, now.month - 5 + i);
      return state
          .where((p) =>
      p.updateAt.month == target.month &&
          p.updateAt.year == target.year)
          .fold(0.0, (sum, p) => sum + (p.price * p.quantity));
    });
  }
//labels des 6 mois derniers
  List<String> get last6MonthsLabels {
    final now = DateTime.now();
    const labels = ['J','F','M','A','M','J','J','A','S','O','N','D'];
    return List.generate(6, (i) {
      final target = DateTime(now.year, now.month - 5 + i);
      return labels[target.month - 1];
    });
  }

  // pourcentages
  List<double> get last6MonthsPercentages {
    final data = last6MonthsExpenses;

    const double reference = 20000.0;

    final double realMax = data.reduce((a, b) => a > b ? a : b);
    final double chartMax = realMax > reference ? realMax : reference;

    return data.map((v) {
      final ratio = v / chartMax;
      return ratio < 0.05 ? 0.05 : ratio;
    }).toList();
  }

// compteur qui compte le nombre d'articles dans shoppingList : achat
int get criticalAlertCount => shoppingList.length;

  //rupture de stock
  bool isOutOfStock(ProductModel product) => product.quantity == 0;

 //alerte si expiringSoon ou critical
bool get hasAlert => criticalAlertCount > 0 || expiringSoonList.isNotEmpty;
}

//recherche par catégories
final filteredProductsProvider = Provider<List<ProductModel>>((ref) {
  final notifier = ref.watch(stockProvider.notifier);
  final allProducts = ref.watch(stockProvider);

  return allProducts.where((product) {
    final matchesCategory = notifier.selectedCategory == 'Tout' ||
        product.category == notifier.selectedCategory;
    final matchesSearch = notifier.searchQuery.isEmpty ||
        product.name.toLowerCase().contains(notifier.searchQuery);
    return matchesCategory && matchesSearch;
  }).toList();
});

final showCriticalOnlyProvider = StateProvider<bool>((ref) => false);

