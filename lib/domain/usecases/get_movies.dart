import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

/// Use case to get list of movies
class GetMovies implements UseCase<List<Movie>, NoParams> {
  final MovieRepository repository;

  GetMovies(this.repository);

  @override
  Future<Either<Failure, List<Movie>>> call(NoParams params) async {
    return await repository.getMovies();
  }
}
