import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/env.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/post_repository.dart';

class FirestoreService implements UserRepository, PostRepository {
  final _db = FirebaseFirestore.instance;

  @override
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _db.collection(Env.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return UserProfile.fromMap({
      'uid': uid,
      'email': data['email'],
      'fullName': data['fullName'],
      'nim': data['nim'],
      'photoUrl': data['photoUrl'],
      'bio': data['bio'],
      'major': data['major'],
      'batch': data['batch'],
      'fcmToken': data['fcmToken'],
      'createdAt': (data['createdAt'] is Timestamp) ? (data['createdAt'] as Timestamp).toDate() : data['createdAt'],
      'updatedAt': (data['updatedAt'] is Timestamp) ? (data['updatedAt'] as Timestamp).toDate() : data['updatedAt'],
    });
  }

  @override
  Future<void> createOrUpdateProfile(UserProfile profile) {
    return _db.collection(Env.usersCollection).doc(profile.uid).set({
      'email': profile.email,
      'fullName': profile.fullName,
      'nim': profile.nim,
      'photoUrl': profile.photoUrl,
      'bio': profile.bio,
      'major': profile.major,
      'batch': profile.batch,
      'fcmToken': profile.fcmToken,
      'createdAt': Timestamp.fromDate(profile.createdAt),
      'updatedAt': profile.updatedAt != null ? Timestamp.fromDate(profile.updatedAt!) : FieldValue.delete(),
    }, SetOptions(merge: true));
  }

  @override
  Stream<List<Post>> posts() {
    return _db.collection(Env.postsCollection).orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) {
            final data = d.data();
            return Post.fromMap({
              'userId': data['userId'],
              'content': data['content'],
              'photoUrl': data['photoUrl'],
              'createdAt': (data['createdAt'] is Timestamp) ? (data['createdAt'] as Timestamp).toDate() : data['createdAt'],
            }, d.id);
          }).toList(),
        );
  }

  @override
  Future<void> createPost(String userId, String content, {String? imageUrl}) async {
    final col = _db.collection(Env.postsCollection);
    await col.add({
      'userId': userId,
      'content': content,
      'photoUrl': imageUrl,
      'createdAt': Timestamp.now(),
    });
  }

  @override
  Future<void> toggleLike(String postId, String userId) async {
    final likeDoc = _db.collection(Env.postsCollection).doc(postId).collection('likes').doc(userId);
    final likeSnap = await likeDoc.get();
    if (likeSnap.exists) {
      await likeDoc.delete();
    } else {
      await likeDoc.set({'createdAt': Timestamp.now()});
    }
  }

  @override
  Future<void> addComment(String postId, String userId, String content) async {
    final col = _db.collection(Env.postsCollection).doc(postId).collection('comments');
    await col.add({
      'postId': postId,
      'userId': userId,
      'content': content,
      'createdAt': Timestamp.now(),
    });
  }

  @override
  Future<int> likeCount(String postId) async {
    final qs = await _db.collection(Env.postsCollection).doc(postId).collection('likes').get();
    return qs.size;
  }

  @override
  Future<int> commentCount(String postId) async {
    final qs = await _db.collection(Env.postsCollection).doc(postId).collection('comments').get();
    return qs.size;
  }

  @override
  Stream<List<Comment>> comments(String postId) {
    return _db
        .collection(Env.postsCollection)
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              return Comment.fromMap({
                'postId': data['postId'],
                'userId': data['userId'],
                'content': data['content'],
                'createdAt': (data['createdAt'] is Timestamp) ? (data['createdAt'] as Timestamp).toDate() : data['createdAt'],
              }, d.id);
            }).toList());
  }
}
