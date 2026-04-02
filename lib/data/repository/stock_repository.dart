import 'package:hive/hive.dart';
import 'package:stock_wise/data/models/product_model.dart';
//CRUD qui permet d'en rajouter dans HIVE , la base de donnée locale
class StockRepository {
  final Box<ProductModel> _productBox = Hive.box<ProductModel>('productsBox');

  //qui prend les produits
  List<ProductModel> getAllProducts() => _productBox.values.toList();

  // put sert à modifier et ajouter , si il existe il écrase l'ancien et le modifie sinon si il n'existe pas il ajoute
  Future<void> saveProducts(ProductModel product) async{
    await _productBox.put(product.id, product);
  }
 //supprimer un produit
  Future<void> deleteProduct(String id) async{
    await _productBox.delete(id);
  }
}