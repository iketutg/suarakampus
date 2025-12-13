import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/env.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/post_repository.dart';

class FirestoreService implements UserRepository, PostRepository {
  final _db = FirebaseFirestore.instance;

  @override
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _db.collection(Env.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return UserProfile.fromMap(data);
  }

  @override
  Future<void> createOrUpdateProfile(UserProfile profile) {
    return _db.collection(Env.usersCollection).doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));
  }

  @override
  Stream<List<Post>> posts() {
    return _db.collection(Env.postsCollection).orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) => Post.fromMap(d.data(), d.id)).toList(),
        );
  }

  @override
  Future<void> createPost(String userId, String content, {String? imageUrl}) async {
    final col = _db.collection(Env.postsCollection);
    await col.add({
      'userId': userId,
      'content': content,
      'imageUrl': imageUrl,
      'likeCount': 0,
      'commentCount': 0,
      'createdAt': DateTime.now().toUtc().millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> toggleLike(String postId, String userId) async {
    final likeDoc = _db.collection(Env.likesCollection).doc('$postId-$userId');
    final postRef = _db.collection(Env.postsCollection).doc(postId);
    await _db.runTransaction((tx) async {
      final likeSnap = await tx.get(likeDoc);
      final postSnap = await tx.get(postRef);
      final currentCount = (postSnap.data()?['likeCount'] ?? 0) as int;
      if (likeSnap.exists) {
        tx.delete(likeDoc);
        tx.update(postRef, {'likeCount': currentCount - 1});
      } else {
        tx.set(likeDoc, {
          'postId': postId,
          'userId': userId,
          'createdAt': DateTime.now().toUtc().millisecondsSinceEpoch,
        });
        tx.update(postRef, {'likeCount': currentCount + 1});
      }
    });
  }

  @override
  Future<void> addComment(String postId, String userId, String content) async {
    final col = _db.collection(Env.commentsCollection);
    final postRef = _db.collection(Env.postsCollection).doc(postId);
    await _db.runTransaction((tx) async {
      tx.set(col.doc(), {
        'postId': postId,
        'userId': userId,
        'content': content,
        'createdAt': DateTime.now().toUtc().millisecondsSinceEpoch,
      });
      final postSnap = await tx.get(postRef);
      final count = (postSnap.data()?['commentCount'] ?? 0) as int;
      tx.update(postRef, {'commentCount': count + 1});
    });
  }
}
