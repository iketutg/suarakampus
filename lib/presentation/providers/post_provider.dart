import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/post.dart';
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

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
