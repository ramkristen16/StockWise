
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stock_wise/data/models/user_model.dart';

class AuthRemoteService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '170248424793-ortbp4ei3n6snmrho6m6k7vgfs24n98c.apps.googleusercontent.com'
        : null,
  );

  final FirebaseFirestore  _db  = FirebaseFirestore.instance;



  //Connexion google
Future<UserModel?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;


    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;


    //création de l'identifiant pour Firebase

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    //connexion à firebase
    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;

    //on récupère ou on crée le profil dans Firestore
    if(user != null){
      return await _getOrCreateUserProfile(user);
    }
  } catch(e){
      debugPrint('[AuthRemoteService] signInWithGoogle error: $e');

  }
  return null;
}

Future<UserModel> _getOrCreateUserProfile(User user) async {
  final doc = await _db.collection('users').doc(user.uid).get();
  //si l'utilisateur existe déjà renvoie ses infos
  if(doc.exists) {
    return UserModel.fromMap(doc.data()!, user.uid);
  } else {
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
}
//déconnexion
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

