class Like {
  final String id;
  final String postId;
  final String userId;
  final DateTime createdAt;

  Like({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'createdAt': createdAt.toUtc().millisecondsSinceEpoch,
    };
  }

  factory Like.fromMap(Map<String, dynamic> map, String id) {
    return Like(
      id: id,
      postId: map['postId'] as String,
      userId: map['userId'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['createdAt'] ?? 0) as int, isUtc: true).toLocal(),
    );
  }
}
