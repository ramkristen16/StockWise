import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stock_wise/data/datasource/auth_remote_service.dart';
import 'package:stock_wise/domain/repositories/auth_repository.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository{
  final AuthRemoteService _remoteService;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthRepositoryImpl(this._remoteService);

  @override
  Future<UserEntity?> signInWithGoogle() async {
    return await _remoteService.signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    await _remoteService.signOut();
  }

  @override
  @override
  Stream<UserEntity?> get onAuthStateChanged {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        final newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          photoUrl: user.photoURL,
          householdId: '',
          role: 'Membre',
        );
        await _db.collection('users').doc(user.uid).set(newUser.toMap());
        return newUser;
      }
      return UserModel.fromMap(doc.data()!, user.uid);
    });
  }

 //créer un foyer :Admin
  @override
  Future<void> createHousehold(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;
    //code à partager
    final String inviteCode = const Uuid().v4().substring(0, 6).toUpperCase();

    final householdRef = _db.collection('households').doc();
    await householdRef.set({
      'id': householdRef.id,
      'name': name,
      'inviteCode': inviteCode,
      'adminId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    //devient admin si il crée
    await _db.collection('users').doc(user.uid).update({
      'householdId': householdRef.id,
      'role': 'Admin',
    });
  }
  //joindre un foyer :Membre
    @override
    Future<void> joinHousehold(String code) async {
      final user = _auth.currentUser;
      if (user == null) return;

      final query = await _db
          .collection('households')
          .where('inviteCode', isEqualTo: code.toUpperCase())
          .get();

      if (query.docs.isEmpty) {
        throw Exception("Code invalide ou foyer inexistant.");
      }

      final householdId = query.docs.first.id;

      await _db.collection('users').doc(user.uid).update({
        'householdId': householdId,
        'role': 'Membre',
      });

    }
   //quitter un foyer: Membre
    @override
    Future<void> leaveHousehold() async {
      final user = _auth.currentUser;
      if (user == null) return;

      await _db.collection('users').doc(user.uid).update({
        'householdId': '',
        'role': 'Membre',
      });
    }
  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    return UserModel.fromMap(doc.data()!, user.uid);
  }

}

