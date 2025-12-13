class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'content': content,
      'createdAt': createdAt.toUtc().millisecondsSinceEpoch,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map, String id) {
    return Comment(
      id: id,
      postId: map['postId'] as String,
      userId: map['userId'] as String,
      content: map['content'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['createdAt'] ?? 0) as int, isUtc: true).toLocal(),
    );
  }
}
