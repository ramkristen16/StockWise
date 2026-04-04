import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/navigation/app_router.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_colors.dart';
import 'data/models/product_model.dart';
//juste test pour Hive et le tab de navigation
void main() async {

  WidgetsFlutterBinding.ensureInitialized();


  await StorageService.init();

  var box = Hive.box<ProductModel>('productsBox');
  final testProduct = ProductModel(
    id: 'test_id_1',
    name: 'Lait de test',
    category: 'Alimentaire',
    location: 'Frigo',
    quantity: 1.0,
    unity: 'kg',
    threshold: 2,
    price: 1.50,
    expiryDate: DateTime.now().add(const Duration(days: 2)),
    updateAt: DateTime.now(),
    isChecked: false,
    idealQuantity: 6.0,
  );

  await box.put(testProduct.id, testProduct);
  debugPrint(" MOTEUR PRÊT : Produit '${box.get('test_id_1')?.name}' chargé !");


  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const MainScaffold(),
    );
  }
}
