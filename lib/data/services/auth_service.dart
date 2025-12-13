import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthService implements AuthRepository {
  final _auth = FirebaseAuth.instance;

  @override
  Stream<String?> authStateChanges() => _auth.authStateChanges().map((u) => u?.uid);

  @override
  Future<String?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user?.uid;
  }

  @override
  Future<String?> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return cred.user?.uid;
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
