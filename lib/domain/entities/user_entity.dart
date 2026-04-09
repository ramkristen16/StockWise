class UserEntity {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? householdId;
  final String role;

  UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.householdId,
    this.role = 'Membre',
  });

  bool get isAdmin => role == 'Admin';
  bool get hasHousehold => householdId != null && householdId!.isNotEmpty;
}
