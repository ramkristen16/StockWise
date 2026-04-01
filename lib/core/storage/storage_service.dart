import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stock_wise/data/models/product_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class StorageService {
  static const _secureStorage = FlutterSecureStorage();
  static const _keyName = 'encryption_key';

  static Future<List<int>> getEncryptionKey() async {
    var keyString = await _secureStorage.read(key: _keyName);
    if(keyString == null){
      final newKey = Hive.generateSecureKey();
      await _secureStorage.write(key: _keyName, value: base64UrlEncode(newKey));
      return newKey;
    }
    return base64Url.decode(keyString);
  }

  static Future<void> init() async {
    await Hive.initFlutter();

  if(!Hive.isAdapterRegistered(0)){
    Hive.registerAdapter(ProductModelAdapter());
  }
  final encryptionKey = await getEncryptionKey();

  await Hive.openBox<ProductModel>(
      'productsBox',
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    await Hive.openBox<ProductModel>(
      'settingsBox',
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    print('Base de donnée (Stok +foyer) chiffrée et prete!');
  }
}
