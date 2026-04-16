import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/member_model.dart';
import '../../data/repository/household_repository_impl.dart';
import '../../domain/entities/household.dart';
import '../../domain/repositories/household_repository.dart';
import 'auth_provider.dart';

final householdRepositoryProvider = Provider<HouseholdRepository>((ref) {
  return HouseholdRepositoryImpl();
});

final householdDetailsProvider = FutureProvider<Household?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null || user.householdId == null || user.householdId!.isEmpty) {
    return null;
  }
  return ref.read(householdRepositoryProvider).getHouseholdDetails(user.householdId!);
});

final householdMembersProvider = StreamProvider<List<MemberModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null || user.householdId == null || user.householdId!.isEmpty) {
    return Stream.value([]);
  }
  return ref.read(householdRepositoryProvider).getMembers(user.householdId!);
});


final familyControllerProvider = StateNotifierProvider<FamilyNotifier, AsyncValue<void>>((ref) {


  return FamilyNotifier(ref.watch(householdRepositoryProvider), ref);
});

class FamilyNotifier extends StateNotifier<AsyncValue<void>> {
  final HouseholdRepository _repository;
  final Ref _ref;

  FamilyNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));


  //Admin peut expulser un membre
  Future<void> removeMember(String memberUid) async {
    final user = _ref.read(authStateProvider).value;
    if (user == null || !user.isAdmin) return;

    state = const AsyncValue.loading();
    try {
      await _repository.removeMember(user.householdId!, memberUid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
