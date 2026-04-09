import '../entities/user_entity.dart';

abstract class AuthRepository {
  //authentification
  Future<UserEntity?> signInWithGoogle();
  Future<void> signOut();
  Stream<UserEntity?> get onAuthStateChanged;

  //gestion du foyer
  Future<void> createHousehold(String name);
  Future<void> joinHousehold(String code);
  Future<void> leaveHousehold();

  // Récupération des données utilisateur
  Future<UserEntity?> getCurrentUser();
}
