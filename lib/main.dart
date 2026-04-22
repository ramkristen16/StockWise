import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stock_wise/presentation/screens/auth/auth_wrapper.dart';
import 'core/notifications/notifications_service.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_colors.dart';
import 'data/models/product_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await StorageService.init();
  await NotificationService.init();
  await NotificationService.requestPermissions();


  final  box = Hive.box<ProductModel>('productsBox');

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
        fontFamily: 'Inter',
      ),
      home: const AuthWrapper(),
    );
  }
}
