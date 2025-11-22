import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_local_data_source.dart';
import '../datasources/movie_remote_data_source.dart';

/// Implementation of MovieRepository
class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;
  final MovieLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MovieRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Movie>>> getMovies() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteMovies = await remoteDataSource.getPopularMovies();
        return Right(remoteMovies.cast<Movie>());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on ConnectionException {
        return Left(ConnectionFailure('No internet connection'));
      } on TimeoutException {
        return Left(TimeoutFailure('Request timeout'));
      } on NetworkException {
        return Left(NetworkFailure('Network error'));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(ConnectionFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> searchMovies(String query) async {
    try {
      final movies = await remoteDataSource.searchMovies(query);
      return Right(movies.cast<Movie>());
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Movie>> getMovieDetails(int id) async {
    try {
      final movie = await remoteDataSource.getMovieById(id);
      return Right(movie);
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getWatchedMovies() async {
    try {
      // Get watched IDs from local storage
      final watchedIds = await localDataSource.getWatchedMovieIds();
      
      if (watchedIds.isEmpty) {
        return const Right([]);
      }

      // Fetch each movie by ID from API
      final movies = <Movie>[];
      for (final id in watchedIds) {
        try {
          final movie = await remoteDataSource.getMovieById(id);
          movies.add(movie);
        } catch (e) {
          // Skip movies that fail to load
          print('Failed to load movie $id: $e');
        }
      }

      return Right(movies);
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getWatchlistMovies() async {
    try {
      // Get watchlist IDs from local storage
      final watchlistIds = await localDataSource.getWatchlistMovieIds();
      
      if (watchlistIds.isEmpty) {
        return const Right([]);
      }

      // Fetch each movie by ID from API
      final movies = <Movie>[];
      for (final id in watchlistIds) {
        try {
          final movie = await remoteDataSource.getMovieById(id);
          movies.add(movie);
        } catch (e) {
          // Skip movies that fail to load
          print('Failed to load movie $id: $e');
        }
      }

      return Right(movies);
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleWatched(int movieId) async {
    try {
      final isWatched = await localDataSource.isWatched(movieId);
      
      if (isWatched) {
        await localDataSource.removeFromWatched(movieId);
      } else {
        await localDataSource.addToWatched(movieId);
      }
      
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to toggle watched: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleWatchlist(int movieId) async {
    try {
      final isInWatchlist = await localDataSource.isInWatchlist(movieId);
      
      if (isInWatchlist) {
        await localDataSource.removeFromWatchlist(movieId);
      } else {
        await localDataSource.addToWatchlist(movieId);
      }
      
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to toggle watchlist: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isWatched(int movieId) async {
    try {
      final result = await localDataSource.isWatched(movieId);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to check watched status: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isInWatchlist(int movieId) async {
    try {
      final result = await localDataSource.isInWatchlist(movieId);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to check watchlist status: $e'));
    }
  }
}
