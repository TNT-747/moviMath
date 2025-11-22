import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/movie_repository.dart';

/// Use case to toggle watched status
class ToggleWatched implements UseCase<void, ToggleWatchedParams> {
  final MovieRepository repository;

  ToggleWatched(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleWatchedParams params) async {
    return await repository.toggleWatched(params.movieId);
  }
}

/// Parameters for ToggleWatched use case
class ToggleWatchedParams extends Equatable {
  final int movieId;

  const ToggleWatchedParams({required this.movieId});

  @override
  List<Object?> get props => [movieId];
}
