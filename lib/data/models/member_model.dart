class MemberModel {
  final String uid;
  final String name;
  final String role;
  final String? photoUrl;

  MemberModel({
    required this.uid,
    required this.name,
    required this.role,
    this.photoUrl
});
  factory MemberModel.fromMap(Map<String, dynamic> map, String id) {
    return MemberModel(
        uid: id,
        name: map['displayName'] ?? 'Anonyme',
        role: map['role'] ?? 'Membre',
        photoUrl: map['photoUrl'],
    );
  }
}