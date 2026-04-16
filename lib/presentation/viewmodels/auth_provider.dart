
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateNotifierProvider, StateNotifier;
import 'package:stock_wise/data/datasource/auth_remote_service.dart';
import 'package:stock_wise/data/repository/auth_repository_impl.dart';
import 'package:stock_wise/domain/entities/user_entity.dart';

import '../../domain/repositories/auth_repository.dart';

final authServiceProvider = Provider((ref) => AuthRemoteService());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authServiceProvider));
});


final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    _repository.onAuthStateChanged.listen(
          (user) => state = AsyncValue.data(user),
      onError: (e) => state = AsyncValue.error(e, StackTrace.current),
    );
  }

  //connexion
  Future<String?> loginWithGoogle() async {
    try {
      state = const AsyncValue.loading();
      final user = await _repository.signInWithGoogle();
      state = AsyncValue.data(user);
      return null;
    } catch (e) {
      state = AsyncValue.data(null);
      return e.toString();
    }
  }

//déconnexion
  Future<void> logout() async {
    await _repository.signOut();
    state = const AsyncValue.data(null);
  }

//créer un foyer
  Future<String?> createHousehold(String name) async {
    try {
      await _repository.createHousehold(name);

      final updatedUser = await _repository.getCurrentUser();

      state = AsyncValue.data(updatedUser);

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  //joindre un foyer
  Future<String?> joinHousehold(String code) async {
    try {
      await _repository.joinHousehold(code);
      final updatedUser = await _repository.getCurrentUser();
      state = AsyncValue.data(updatedUser);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
//quitter un foyer
  Future<String?> leaveHousehold() async {
    try {
      await _repository.leaveHousehold();
      state = AsyncValue.data(await _repository.getCurrentUser());
      return null;
    } catch (e) {
      return e.toString();
    }
  }



}
