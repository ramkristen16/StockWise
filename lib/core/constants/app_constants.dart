class ProductCategory {

  static const String alimentaire = 'Alimentaire';
  static const String hygiene = 'Hygiène';
  static const String entretien = 'Entretien';
  static const String energie = 'Energie';
  static const String sante = 'Santé';
  static const String autre = 'Autre';

  //liste complète des catégories
 static const List<String> all = [
   alimentaire,hygiene,entretien,energie,sante,autre,
 ];

 //Icone par catégories
static String iconOf(String category) {
  switch (category) {
    case alimentaire: return'🥗';
    case hygiene:     return '🧴';
    case entretien:   return '🧹';
    case energie:     return '⚡';
    case sante:       return '💊';
    case autre: return '📦';
    default:          return '📦';

  }
 }
}

class ProductLocation {

  static const String frigo = 'Frigo';
  static const String congelateur = 'Congélateur';
  static const String placard = 'Placard cuisine';
  static const String gardeManger = 'Garde-manger';
  static const String salleDeBain = 'Salle de bain';
  static const String autre = 'Autre';

  static const List<String> all = [
    frigo, congelateur, placard, gardeManger, salleDeBain, autre
  ];

  static String iconOf(String location) {
    switch (location) {
      case frigo:          return '🧊';
      case congelateur:    return '❄️';
      case placard: return '🚪';
      case gardeManger:    return '🏠';
      case salleDeBain:    return '🚿';
      case autre: return '📍';
      default:             return '📍';
    }
  }
}

class MemberRole {
  static const String admin = 'Admin';
  static const String member = 'Membre';
}

