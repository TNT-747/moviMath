import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/movie.dart';

/// Abstract repository interface for movie operations
abstract class MovieRepository {
  /// Get list of movies
  Future<Either<Failure, List<Movie>>> getMovies();

  /// Search movies by query
  Future<Either<Failure, List<Movie>>> searchMovies(String query);

  /// Get movie details by ID
  Future<Either<Failure, Movie>> getMovieDetails(int id);

  /// Get list of watched movies
  Future<Either<Failure, List<Movie>>> getWatchedMovies();

  /// Get list of watchlist movies
  Future<Either<Failure, List<Movie>>> getWatchlistMovies();

  /// Toggle watched status for a movie
  Future<Either<Failure, void>> toggleWatched(int movieId);

  /// Toggle watchlist status for a movie
  Future<Either<Failure, void>> toggleWatchlist(int movieId);

  /// Check if movie is watched
  Future<Either<Failure, bool>> isWatched(int movieId);

  /// Check if movie is in watchlist
  Future<Either<Failure, bool>> isInWatchlist(int movieId);
}
