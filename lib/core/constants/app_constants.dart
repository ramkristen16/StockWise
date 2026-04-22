class ProductCategory {

  static const String alimentaire = 'Alimentaire';
  static const String hygiene = 'Hygiène';
  static const String entretien = 'Entretien';
  static const String energie = 'Energie';
  static const String sante = 'Santé';
  static const String autre = 'Autre';
  static String get homeIcon => 'assets/Icon/garde.svg';


  //liste complète des catégories
 static const List<String> all = [
   alimentaire,hygiene,entretien,energie,sante,autre,
 ];

 //Icone par catégories
  static String iconOf(String category) {
    switch (category) {
      case alimentaire:
        return 'assets/Icon/alimentaire.svg';
      case hygiene:
        return 'assets/Icon/hygiene.svg';
      case entretien:
        return 'assets/Icon/entretien.svg';
      case energie:
        return 'assets/Icon/energie.svg';
      case sante:
        return 'assets/Icon/sante.svg';
      case autre:
        return 'assets/Icon/autre.svg';
      default:
        return 'assets/Icon/autre.svg';
    }
  }

}

class ProductLocation {
  static const String define = 'A définir';
  static const String frigo = 'Frigo';
  static const String congelateur = 'Congélateur';
  static const String placard = 'Placard cuisine';
  static const String gardeManger = 'Garde-manger';
  static const String salleDeBain = 'Salle de bain';
  static const String autre = 'Autre';

  static const List<String> all = [
    frigo, congelateur, placard, gardeManger, salleDeBain, autre , define
  ];

  static String iconOf(String location) {
    switch (location) {
      case define:       return 'assets/Icon/define.svg';
      case frigo:        return 'assets/Icon/fridge.svg';
      case congelateur:  return 'assets/Icon/frigo.svg';
      case placard:      return 'assets/Icon/placard.svg';
      case gardeManger:  return 'assets/Icon/garde.svg';
      case salleDeBain:  return 'assets/Icon/shower.svg';
      case autre:        return 'assets/Icon/fluent-emoji-flat_round-pushpin.svg';
      default:           return 'assets/Icon/fluent-emoji-flat_round-pushpin.svg';
    }
  }

}

class MemberRole {
  static const String admin = 'Admin';
  static const String member = 'Membre';
}


class AppRoutes {
  static const String dashboard    = '/';
  static const String stock        = '/stock';
  static const String shopping     = '/shopping';
  static const String addProduct   = '/add-product';
  static const String family       = '/family';
}

//index pour le tab de navigation
class NavTab {
  static const int dashboard  = 0;
  static const int stock      = 1;
  static const int shopping   = 2;
  static const int addProduct = 3;
  static const int family     = 4;

  //label en bas de chaque icone de navigation
  static const List<String> labels = [
    'Accueil',
    'Stock',
    'Course',
    'Ajouter',
    'Famille',
  ];
}
class StockStatus {
  static const String active   = 'active';
  static const String critical = 'critical';
  static const String pending  = 'pending';
}


class ProductUnits {
  static const List<String> units =[
    'unités', 'kg', 'g', 'L', 'mL', 'pcs',
    'boîte', 'sachet', 'bouteille', 'rouleau', 'plaquette'
  ] ;
}
