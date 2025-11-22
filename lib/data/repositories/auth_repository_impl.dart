import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../models/user_model.dart';

/// Implementation of AuthRepository with simulated authentication
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Simulated authentication - just check if fields are not empty
      if (email.isEmpty || password.isEmpty) {
        return const Left(ValidationFailure('Email and password are required'));
      }

      // Create a simulated user
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: email.split('@')[0], // Use email prefix as name
      );

      // Cache the user
      await localDataSource.cacheUser(user);

      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Login failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Simulated authentication - just check if fields are not empty
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return const Left(ValidationFailure('All fields are required'));
      }

      // Create a simulated user
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
      );

      // Cache the user
      await localDataSource.cacheUser(user);

      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Signup failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Logout failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User?>> checkAuthStatus() async {
    try {
      final isLoggedIn = await localDataSource.isLoggedIn();
      if (!isLoggedIn) {
        return const Right(null);
      }

      final user = await localDataSource.getCachedUser();
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to check auth status: ${e.toString()}'));
    }
  }
}
