class UserProfile {
  final String uid;
  final String email;
  final String fullName;
  final String? nim;
  final String? photoUrl;
  final String? bio;
  final String? major;
  final String? batch;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.fullName,
    this.nim,
    this.photoUrl,
    this.bio,
    this.major,
    this.batch,
    this.fcmToken,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final created = map['createdAt'];
    final updated = map['updatedAt'];
    DateTime createdAt;
    DateTime? updatedAt;
    if (created is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(created, isUtc: true).toLocal();
    } else if (created is DateTime) {
      createdAt = created;
    } else {
      createdAt = DateTime.now();
    }
    if (updated is int) {
      updatedAt = DateTime.fromMillisecondsSinceEpoch(updated, isUtc: true).toLocal();
    } else if (updated is DateTime) {
      updatedAt = updated;
    } else {
      updatedAt = null;
    }
    return UserProfile(
      uid: map['uid'] as String,
      email: map['email'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      nim: map['nim'] as String?,
      photoUrl: map['photoUrl'] as String?,
      bio: map['bio'] as String?,
      major: map['major'] as String?,
      batch: map['batch'] as String?,
      fcmToken: map['fcmToken'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
