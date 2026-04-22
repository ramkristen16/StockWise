
import '../../core/constants/app_constants.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final String location;
  final double quantity;
  final String unity;
  final int threshold;
  final double price;
  final DateTime? expiryDate;
  final DateTime updateAt;
  final bool isChecked;
  final double idealQuantity;
  final String status;
  final String householdId;

  Product({
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
    this.idealQuantity = 1.0,
    this.status = StockStatus.active,
    required this.householdId,
    });
  //Si la quantité est inférieur ou égale au seuil critique , fait true : il est critque sinon false
  bool get isCritical => quantity <= threshold;

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }


  //si il reste que 0 à 3 entre la date d'expiration est aujourd'hui , fait true : il va bientot s'expirer sinon false
  bool get isExpiringSoon {
    final date = expiryDate;
    if (date == null) return false;

    final maintenant = DateTime.now();

    final aujourdhui = DateTime(maintenant.year, maintenant.month, maintenant.day);
    final dateExpiration = DateTime(date.year, date.month, date.day);

    final jourRestants = dateExpiration.difference(aujourdhui).inDays;

    return jourRestants >= 0 && jourRestants <= 3;
  }

}