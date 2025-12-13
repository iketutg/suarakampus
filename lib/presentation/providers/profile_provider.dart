import 'package:flutter/foundation.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final UserRepository _repo;
  UserProfile? profile;
  bool loading = false;
  String? error;

  ProfileProvider(this._repo);

  Future<void> load(String uid) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      profile = await _repo.getProfile(uid);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> update(UserProfile p) async {
    await _repo.createOrUpdateProfile(p);
    profile = p;
    notifyListeners();
  }

  Future<UserProfile?> getById(String uid) {
    return _repo.getProfile(uid);
  }
}
