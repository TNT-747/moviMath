import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

/// Use case to get movie details
class GetMovieDetails implements UseCase<Movie, MovieDetailsParams> {
  final MovieRepository repository;

  GetMovieDetails(this.repository);

  @override
  Future<Either<Failure, Movie>> call(MovieDetailsParams params) async {
    return await repository.getMovieDetails(params.id);
  }
}

/// Parameters for GetMovieDetails use case
class MovieDetailsParams extends Equatable {
  final int id;

  const MovieDetailsParams({required this.id});

  @override
  List<Object?> get props => [id];
}
