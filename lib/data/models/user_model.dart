import 'package:hive/hive.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends UserEntity {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String displayName;

  @HiveField(3)
  final String? photoUrl;

  @HiveField(4)
  final String? householdId;

  @HiveField(5)
  final String role;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.householdId,
    this.role = 'Membre',
  }) : super(
    uid: uid,
    email: email,
    displayName: displayName,
    photoUrl: photoUrl,
    householdId: householdId,
    role: role,
  );

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      householdId: map['householdId'],
      role: map['role'] ?? 'Membre',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'householdId': householdId,
      'role': role,
    };
  }
}
