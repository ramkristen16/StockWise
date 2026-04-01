import 'package:hive/hive.dart';

import '../../domain/entities/product.dart';
part 'product_model.g.dart';// se crée automatique
//mettre chaque model dans hive avec une index : représente un attribut
@HiveType(typeId: 0)
class ProductModel extends Product{
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String location;

  @HiveField(4)
  final double quantity;

  @HiveField(5)
  final String unity;

  @HiveField(6)
  final int threshold;

  @HiveField(7)
  final double price;

  @HiveField(8)
  final  DateTime expiryDate;

  @HiveField(9)
  final  DateTime updateAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.quantity,
    required this.unity,
    required this.threshold,
    required this.price,
    required this.expiryDate,
    required this.updateAt,
 }) : super(
        id:  id,
        name: name,
        category: category,
        location: location,
        quantity: quantity,
        unity: unity,
        threshold: threshold,
        price: price,
        expiryDate: expiryDate,
        updateAt: updateAt

      );


}



