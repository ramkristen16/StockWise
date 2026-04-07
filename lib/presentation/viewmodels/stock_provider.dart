import 'package:flutter/cupertino.dart';
import 'package:riverpod/legacy.dart';
import 'package:stock_wise/data/models/product_model.dart';
import 'package:stock_wise/data/repository/stock_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final stockProvider = StateNotifierProvider<StockNotifier, List<ProductModel>>((ref){
  return StockNotifier(StockRepository());
});


class StockNotifier extends StateNotifier<List<ProductModel>> {
  final StockRepository _repository;
  String _searchQuery = '';
  String _selectedCategory = 'Tout';
  StockNotifier(this._repository) : super([]) {
    loadProducts();
  }
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  Future<void> loadProducts() async {
    try {
      state = await _repository.getAllProducts();
    } catch (e){
      debugPrint('[StockNotifier] loadProducts error: $e');
    }
  }

  Future<void> addOrUpdateProduct(ProductModel product) async {

    try{
      await _repository.saveProducts(product);
      await loadProducts();
    }
    catch (e){
      debugPrint('[StockNotifier] addOrUpdateProduct erreor: $e');
    }
  }

  Future<void> removeProduct(String id) async {
    try{
      await _repository.deleteProduct(id);
      await loadProducts();
    }
    catch (e){
      debugPrint('[StockNotifier] removeProduct error: $e');
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
        quantity : product.quantity - 1,
        updateAt : DateTime.now(),
      );
      await addOrUpdateProduct(updated);
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

  //Valider l'achat
 Future<void> validatePurchase(ProductModel product, int newQuantity, double newPrice) async{
    final updated = product.copyWith(
      quantity: product.quantity + newQuantity,
      price: newPrice,
      updateAt: DateTime.now(),
    );
    await addOrUpdateProduct(updated);
 }
  //Liste de course : produits en dessous du seuil
 List<ProductModel> get shoppingList =>
     state.where((p) => p.isCritical).toList();

  // Liste des produits qui s'expirent bientôt
 List<ProductModel> get expiringSoonList =>
     state.where((p) => p.isExpiringSoon).toList();

 //action ou on coche un produit dans l'achat de shoppingList
  void toggleCheck(ProductModel product){
    final updated = product.copyWith(isChecked: !product.isChecked);
    addOrUpdateProduct(updated);
  }

  //valeur totale du stock présents dans les emplacements meme pas critique
 double get totalStockValue =>
     state.fold(0.0,(total,item) => total +(item.price * item.quantity));

  //valeur de ce qu'il achète au moment de l'achat : les produits achetés dans shoopingList
  double get checkedShoppingList {
    return shoppingList
        .where((p) => p.isChecked)
        .fold(0.0,(total,item) => total +(item.price * item.idealQuantity));
  }
  //valeur des stocks dans le shoopingList
 double get estimatedShoppingTotal {
   return shoppingList.fold(0.0, (total,item) => total +(item.price * item.idealQuantity));

 }

 //dépenses mensuels
 double get monthlyExpenses {
   final now = DateTime.now();
   return state
       .where((p) => p.updateAt.month == now.month && p.updateAt.year == now.year)
       .fold(0.0, (total,item) => total +(item.price * item.quantity));
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

