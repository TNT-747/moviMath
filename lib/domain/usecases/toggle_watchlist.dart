import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/movie_repository.dart';

/// Use case to toggle watchlist status
class ToggleWatchlist implements UseCase<void, ToggleWatchlistParams> {
  final MovieRepository repository;

  ToggleWatchlist(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleWatchlistParams params) async {
    return await repository.toggleWatchlist(params.movieId);
  }
}

/// Parameters for ToggleWatchlist use case
class ToggleWatchlistParams extends Equatable {
  final int movieId;

  const ToggleWatchlistParams({required this.movieId});

  @override
  List<Object?> get props => [movieId];
}
