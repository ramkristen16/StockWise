
import 'package:stock_wise/domain/entities/household.dart';

import '../../data/models/member_model.dart';

abstract class HouseholdRepository {
  Future<Household?> getHouseholdDetails(String householdId);
  Stream<List<MemberModel>> getMembers(String householdId);
  Future<void> removeMember(String householdId, String memberUid);
}