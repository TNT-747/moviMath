import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/user.dart';

/// Abstract repository defining authentication operations
abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Signup with name, email, and password
  Future<Either<Failure, User>> signup({
    required String name,
    required String email,
    required String password,
  });

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Check if user is currently authenticated
  Future<Either<Failure, User?>> checkAuthStatus();
}
