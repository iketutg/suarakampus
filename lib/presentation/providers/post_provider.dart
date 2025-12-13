import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/post_repository.dart';

class PostProvider extends ChangeNotifier {
  final PostRepository _repo;
  List<Post> posts = [];
  StreamSubscription? _sub;

  PostProvider(this._repo) {
    _sub = _repo.posts().listen((data) {
      posts = data;
      notifyListeners();
    });
  }

  Future<void> create(String userId, String content, {String? imageUrl}) {
    return _repo.createPost(userId, content, imageUrl: imageUrl);
  }

  Future<void> toggleLike(String postId, String userId) {
    return _repo.toggleLike(postId, userId);
  }

  Future<int> likeCountFor(String postId) => _repo.likeCount(postId);
  Future<int> commentCountFor(String postId) => _repo.commentCount(postId);
  Stream<List<Comment>> commentsFor(String postId) => _repo.comments(postId);
  Future<void> addComment(String postId, String userId, String content) => _repo.addComment(postId, userId, content);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
