class Post {
  final String id;
  final String userId;
  final String content;
  final String? photoUrl;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    this.photoUrl,
    required this.createdAt,
  });

  factory Post.fromMap(Map<String, dynamic> map, String id) {
    final created = map['createdAt'];
    DateTime createdAt;
    if (created is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(created, isUtc: true).toLocal();
    } else if (created is DateTime) {
      createdAt = created;
    } else {
      createdAt = DateTime.now();
    }
    return Post(
      id: id,
      userId: map['userId'] as String? ?? '',
      content: map['content'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      createdAt: createdAt,
    );
  }
}
