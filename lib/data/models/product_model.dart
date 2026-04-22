import 'package:hive/hive.dart';
import 'package:stock_wise/core/constants/app_constants.dart';

import '../../domain/entities/product.dart';
part 'product_model.g.dart';// se crée automatique

 const _sentinel = Object();

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
  final  DateTime? expiryDate;

  @HiveField(9)
  final  DateTime updateAt;

  @HiveField(10)
  final bool isChecked;

  @HiveField(11)
  final double idealQuantity;

  @HiveField(12)
  final String status;

  @HiveField(13)
  final String householdId;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.quantity,
    required this.unity,
    required this.threshold,
    required this.price,
    this.expiryDate,
    required this.updateAt,
    this.isChecked = false,
    this.idealQuantity = 0,
    this.status = StockStatus.active,
    required this.householdId,
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
        status: status,
        householdId: householdId,

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
    Object? expiryDate = _sentinel,
    DateTime? updateAt,
    bool? isChecked,
    double? idealQuantity,
    String? status,
    String? householdId,

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
      expiryDate: expiryDate == _sentinel ? this.expiryDate : expiryDate as DateTime?,
      updateAt: updateAt ?? this.updateAt,
      isChecked: isChecked ?? this.isChecked,
      idealQuantity: idealQuantity ?? this.idealQuantity,
      status: status ?? this.status,
      householdId: householdId ?? this.householdId,

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'location': location,
      'quantity': quantity,
      'unity': unity,
      'threshold': threshold,
      'price': price,
      'expiryDate': expiryDate?.toIso8601String(),
      'updateAt': updateAt.toIso8601String(),
      'isChecked': isChecked,
      'idealQuantity': idealQuantity,
      'status': status,
      'householdId': householdId,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      unity: map['unity'] ?? '',
      threshold: (map['threshold'] ?? 0).toInt(),
      price: (map['price'] ?? 0).toDouble(),
      expiryDate: map['expiryDate'] != null ? DateTime.parse(map['expiryDate']) : null,
      updateAt: map['updateAt'] != null ? DateTime.parse(map['updateAt']) : DateTime.now(),
      isChecked: map['isChecked'] ?? false,
      idealQuantity: (map['idealQuantity'] ?? 0).toDouble(),
      status: map['status'] ?? 'active',
      householdId: map['householdId'] ?? '',
    );
  }

  factory ProductModel.empty() => ProductModel(
    id: '', name: '', category: '', location: '',
    quantity: 0, unity: '', threshold: 0, price: 0,
    updateAt: DateTime.now(), householdId: '',
  );



}



