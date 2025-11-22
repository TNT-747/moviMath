import 'package:hive/hive.dart';

import '../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Abstract interface for authentication local data source
abstract class AuthLocalDataSource {
  /// Get cached user data
  Future<UserModel?> getCachedUser();

  /// Cache user data
  Future<void> cacheUser(UserModel user);

  /// Clear cached user data
  Future<void> clearCache();

  /// Check if user is logged in
  Future<bool> isLoggedIn();
}

/// Implementation of AuthLocalDataSource using Hive
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box box;

  static const String _userKey = 'cached_user';
  static const String _isLoggedInKey = 'is_logged_in';

  AuthLocalDataSourceImpl({required this.box});

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = box.get(_userKey);
      if (userJson != null) {
        return UserModel.fromJson(Map<String, dynamic>.from(userJson));
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached user: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await box.put(_userKey, user.toJson());
      await box.put(_isLoggedInKey, true);
    } catch (e) {
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await box.delete(_userKey);
      await box.put(_isLoggedInKey, false);
    } catch (e) {
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return box.get(_isLoggedInKey, defaultValue: false) as bool;
    } catch (e) {
      throw CacheException('Failed to check login status: ${e.toString()}');
    }
  }
}
