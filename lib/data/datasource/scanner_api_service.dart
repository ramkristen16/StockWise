
import 'package:dio/dio.dart';

class ScannerApiService {

  final Dio _dio = Dio();

  Future<Map<String,dynamic>?> getProductFromBarcode(String barcode) async{
    //endpoint openfoodfact util pour la détection des produits scannés
    final String url = 'https://world.openfoodfacts.org/api/v2/product/$barcode.json';

    try {
      final response = await _dio.get(url);
      if(response.statusCode == 200){
        final data = response.data;
      //scan correct mais inconnu dans la base
        if(data['status'] == 0) {
          return {
            'name' : '',
            'category' : 'Alimentaire',
            'notFound' : true,
          };
        }
        //produit connu
        if(data['status'] == 1 ) {
          final product = data['product'];
          final categoryTags = product['categories_tags'] as List? ?? [];

          return {
            'name': product['product_name'] ?? '',
            'category' : _mapCategory(categoryTags),
            'brand': product['brands'] ?? '',
            'image' : product['image_front_url'] ?? '',
            'notFound' : false,
          };
        }
      }
    //gestion des erreurs
    } on DioException catch(e){
      print('[ScannerApiService] Erreur réseau : ${e.message}');
    } catch (e) {
      print('[ScannerApiService Erreur inconnue : $e');
    }
    return null;
  }
  //convertition des tags complexes d'OpenFoodFacts en catégories utilisables et simples
  String _mapCategory(List tags) {
    if(tags.isEmpty) return 'Alimentaire';
    final raw = tags.first.toString().split(':').last.toLowerCase();


    //produit alimentaire en les détectants par les mots clés
    if (raw.contains('dairy') || raw.contains('lait')) return 'Alimentaire';
    if (raw.contains('beverage') || raw.contains('drink')) return 'Alimentaire';
    if (raw.contains('cereal') || raw.contains('bread')) return 'Alimentaire';
    if (raw.contains('meat') || raw.contains('fish')) return 'Alimentaire';

   //produit non alimentaire
    if (raw.contains('hygiene') || raw.contains('soap')) return 'Hygiène';
    if (raw.contains('cleaning') || raw.contains('detergent')) return 'Entretien';
    if (raw.contains('medicine') || raw.contains('health')) return 'Santé';
    if (raw.contains('energy') || raw.contains('gas')) return 'Energie';


    return 'Alimentaire' ;
  }


}