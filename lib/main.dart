import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/storage/storage_service.dart';
import 'data/models/product_model.dart';

void main() async {
  // 1. Initialisation obligatoire de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialisation de ton moteur (Secure Storage + Hive)
  await StorageService.init();

  // 3. --- PETIT TEST POUR VOIR SI ÇA MARCHE (CONSOLE) ---
  var box = Hive.box<ProductModel>('productsBox');

  final testLait = ProductModel(
    id: 'test_id_1',
    name: 'Lait de test',
    category: 'Alimentaire',
    location: 'Frigo',
    quantity: 1.0,      // Bas pour tester l'alerte
    unity: 'kg',
    threshold: 2,     // Seuil
    price: 1.50,
    expiryDate: DateTime.now().add(const Duration(days: 2)),
    updateAt: DateTime.now(),
  );

  // On enregistre et on relit direct
  await box.put(testLait.id, testLait);
  final produitLu = box.get('test_id_1');

  if (produitLu != null) {
    print("------------------------------------------");
    print("🚀 SUCCÈS : Produit '${produitLu.name}' lu dans le coffre !");
    print("⚠️ ALERTE STOCK : ${produitLu.isCritical}"); // Doit afficher true
    print("------------------------------------------");
  }
  // -----------------------------------------------------

  // 4. Lancement de l'interface
  runApp(const MyApp());
}

// C'est ce widget qui manquait ou qui avait une erreur
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            '✅ Moteur StockWise : Sécurisé et Prêt\n(Regarde la console de debug !)',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
