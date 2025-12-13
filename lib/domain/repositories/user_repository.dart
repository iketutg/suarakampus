import '../entities/user_profile.dart';

abstract class UserRepository {
  Future<UserProfile?> getProfile(String uid);
  Future<void> createOrUpdateProfile(UserProfile profile);
}
