import '../entities/post.dart';

abstract class PostRepository {
  Stream<List<Post>> posts();
  Future<void> createPost(String userId, String content, {String? imageUrl});
  Future<void> toggleLike(String postId, String userId);
  Future<void> addComment(String postId, String userId, String content);
}
