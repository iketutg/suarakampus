class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'createdAt': createdAt.toUtc().millisecondsSinceEpoch,
      'updatedAt': updatedAt.toUtc().millisecondsSinceEpoch,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      bio: map['bio'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['createdAt'] ?? 0) as int, isUtc: true).toLocal(),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((map['updatedAt'] ?? 0) as int, isUtc: true).toLocal(),
    );
  }
}
