import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:stock_wise/data/models/product_model.dart';
//CRUD qui permet d'en rajouter dans HIVE , la base de donnée locale
class StockRepository {
  //hive
  final Box<ProductModel> _productBox = Hive.box<ProductModel>('productsBox');
//firebase
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //qui prend les produits par foyer
  Future<List<ProductModel>> getAllProducts(String householdId) async {
    return _productBox.values.where((p) => p.householdId == householdId).toList();
  }

  // put sert à modifier et ajouter , si il existe il écrase l'ancien et le modifie sinon si il n'existe pas il ajoute
  Future<void> saveProducts(ProductModel product) async{
    await _productBox.put(product.id, product);

    _db.collection('products').doc(product.id).set(product.toMap())
        .then((_) => print("Synchro Firebase réussie pour: ${product.name}"))
        .catchError((e) => print("Firebase : Donnée en attente de connexion ($e)"));

    print("Enregistrement Firebase OK pour le produit: ${product.name}");

  }
 //supprimer un produit
  Future<void> deleteProduct(String id) async{
    await _productBox.delete(id);
    _db.collection('products').doc(id).delete()
        .then((_) => print("Suppression Firebase OK"))
        .catchError((e) => print("Suppression Cloud en attente ($e)"));

  }
  //écoute automatique
  Stream<void> syncFromFirestore(String householdId) {
    return _db.collection('products')
        .where('householdId', isEqualTo: householdId)
        .snapshots()
        .map((snapshot) {
      for (var doc in snapshot.docs) {
        final product = ProductModel.fromMap(doc.data(), doc.id);
        _productBox.put(product.id, product);
      }
    });
  }


}