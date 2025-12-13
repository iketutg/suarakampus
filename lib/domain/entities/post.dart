class Post {
  final String id;
  final String userId;
  final String content;
  final String? imageUrl;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'imageUrl': imageUrl,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'createdAt': createdAt.toUtc().millisecondsSinceEpoch,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map, String id) {
    return Post(
      id: id,
      userId: map['userId'] as String,
      content: map['content'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      likeCount: (map['likeCount'] ?? 0) as int,
      commentCount: (map['commentCount'] ?? 0) as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['createdAt'] ?? 0) as int, isUtc: true).toLocal(),
    );
  }
}
