
//procduct model , tous ce dont nous avons besoin
class Product {
  final String id;
  final String name;
  final String category;
  final String location;
  final double quantity;
  final String unity;
  final int threshold;
  final double price;
  final DateTime expiryDate;
  final DateTime updateAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.quantity,
    required this.unity,
    required this.threshold,
    required this.price,
    required this.expiryDate,
    required this.updateAt
    });
  //Si la quantité est inférieur ou égale au seuil critique , fait true : il est critque sinon false
  bool get isCritical => quantity <= threshold;

  //si il reste que 0 à 3 entre la date d'expiration est aujourd'hui , fait true : il va bientot s'expirer sinon false
  bool get isExpiringSoon {
    DateTime aujourdhui = DateTime.now();
    int jourRestants = expiryDate.difference(aujourdhui).inDays;
    if (jourRestants >= 0 && jourRestants <= 3){
      return true;
    }
    else {
      return false;
    }
  }

}