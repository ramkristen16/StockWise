
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_wise/domain/entities/household.dart';

import '../../domain/repositories/household_repository.dart';
import '../models/member_model.dart';
import 'package:stock_wise/data/models/household_model.dart';


class HouseholdRepositoryImpl implements HouseholdRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  @override
  Future<Household?> getHouseholdDetails(String householdId) async {
    final doc = await _db.collection('households').doc(householdId).get();
    if (!doc.exists) return null;
    return HouseholdModel.fromMap(doc.data()!, doc.id);
  }

//voir membre
  @override
  Stream<List<MemberModel>> getMembers(String householdId) {
    return _db.collection('users')
        .where('householdId', isEqualTo: householdId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs
            .map((doc) => MemberModel.fromMap(doc.data(), doc.id))
            .toList());
  }
//supprime un membre
  @override
  Future<void> removeMember(String householdId, String memberUid) async {
    await _db.collection('users').doc(memberUid).update({
      'householdId': '',
      'role': 'Membre',
    });
  }

}