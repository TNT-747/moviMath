import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any authentication action
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during authentication operations
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state with user data
class Authenticated extends AuthState {
  final User user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state (logged out or not logged in)
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Error state with error message
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
