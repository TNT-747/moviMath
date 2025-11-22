import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

/// Use case for searching movies
class SearchMovies implements UseCase<List<Movie>, SearchMoviesParams> {
  final MovieRepository repository;

  SearchMovies(this.repository);

  @override
  Future<Either<Failure, List<Movie>>> call(SearchMoviesParams params) async {
    return await repository.searchMovies(params.query);
  }
}

/// Parameters for SearchMovies use case
class SearchMoviesParams extends Equatable {
  final String query;

  const SearchMoviesParams({required this.query});

  @override
  List<Object> get props => [query];
}
