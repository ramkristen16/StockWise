import 'package:hive/hive.dart';
import '../../domain/entities/household.dart';
part 'household_model.g.dart';

@HiveType(typeId: 2)
class HouseholdModel extends Household {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String inviteCode;

  @HiveField(3)
  final String adminId;

  HouseholdModel({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.adminId,
  }) : super(
    id: id,
    name: name,
    inviteCode: inviteCode,
    adminId: adminId,
  );

  factory HouseholdModel.fromMap(Map<String, dynamic> map, String documentId) {
    return HouseholdModel(
      id: documentId,
      name: map['name'] ?? '',
      inviteCode: map['inviteCode'] ?? '',
      adminId: map['adminId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'inviteCode': inviteCode,
      'adminId': adminId,
    };
  }
}
