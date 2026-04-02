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

  @HiveField(10)
  final bool isChecked;

  @HiveField(11)
  final double idealQuantity;

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
    this.isChecked = false,
    this.idealQuantity = 0,
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
        updateAt: updateAt,
        isChecked: isChecked,
        idealQuantity: idealQuantity,

      );

  ProductModel copyWith({
    String? id,
    String? name,
    String? category,
    String? location,
    double? quantity,
    String? unity,
    int? threshold,
    double? price,
    DateTime? expiryDate,
    DateTime? updateAt,
    bool? isChecked,
    double? idealQuantity,

}) {
    return ProductModel(
      id: id?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      location: location ?? this.location,
      quantity: quantity ?? this.quantity,
      unity: unity ?? this.unity,
      threshold: threshold ?? this.threshold,
      price: price ?? this.price,
      expiryDate: expiryDate ?? this.expiryDate,
      updateAt: updateAt ?? this.updateAt,
      isChecked: isChecked ?? this.isChecked,
      idealQuantity: idealQuantity ?? this.idealQuantity,

    );
  }


}



