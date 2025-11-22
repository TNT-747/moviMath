import 'package:hive/hive.dart';

import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';

/// Abstract interface for movie local data source
/// Stores only movie IDs for watched and watchlist
abstract class MovieLocalDataSource {
  /// Get watched movie IDs
  Future<Set<int>> getWatchedMovieIds();

  /// Get watchlist movie IDs
  Future<Set<int>> getWatchlistMovieIds();

  /// Add movie to watched list
  Future<void> addToWatched(int movieId);

  /// Remove movie from watched list
  Future<void> removeFromWatched(int movieId);

  /// Add movie to watchlist
  Future<void> addToWatchlist(int movieId);

  /// Remove movie from watchlist
  Future<void> removeFromWatchlist(int movieId);

  /// Check if movie is watched
  Future<bool> isWatched(int movieId);

  /// Check if movie is in watchlist
  Future<bool> isInWatchlist(int movieId);
}

/// Implementation of MovieLocalDataSource using Hive
/// Stores only movie IDs in user_preferences box
class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  final Box box;

  MovieLocalDataSourceImpl({required this.box});

  @override
  Future<Set<int>> getWatchedMovieIds() async {
    try {
      final watched = box.get(AppConstants.watchedKey, defaultValue: <int>[]) as List;
      return watched.cast<int>().toSet();
    } catch (e) {
      throw CacheException('Failed to get watched movies: ${e.toString()}');
    }
  }

  @override
  Future<Set<int>> getWatchlistMovieIds() async {
    try {
      final watchlist = box.get(AppConstants.watchlistKey, defaultValue: <int>[]) as List;
      return watchlist.cast<int>().toSet();
    } catch (e) {
      throw CacheException('Failed to get watchlist: ${e.toString()}');
    }
  }

  @override
  Future<void> addToWatched(int movieId) async {
    try {
      final watched = await getWatchedMovieIds();
      watched.add(movieId);
      await box.put(AppConstants.watchedKey, watched.toList());
    } catch (e) {
      throw CacheException('Failed to add to watched: ${e.toString()}');
    }
  }

  @override
  Future<void> removeFromWatched(int movieId) async {
    try {
      final watched = await getWatchedMovieIds();
      watched.remove(movieId);
      await box.put(AppConstants.watchedKey, watched.toList());
    } catch (e) {
      throw CacheException('Failed to remove from watched: ${e.toString()}');
    }
  }

  @override
  Future<void> addToWatchlist(int movieId) async {
    try {
      final watchlist = await getWatchlistMovieIds();
      watchlist.add(movieId);
      await box.put(AppConstants.watchlistKey, watchlist.toList());
    } catch (e) {
      throw CacheException('Failed to add to watchlist: ${e.toString()}');
    }
  }

  @override
  Future<void> removeFromWatchlist(int movieId) async {
    try {
      final watchlist = await getWatchlistMovieIds();
      watchlist.remove(movieId);
      await box.put(AppConstants.watchlistKey, watchlist.toList());
    } catch (e) {
      throw CacheException('Failed to remove from watchlist: ${e.toString()}');
    }
  }

  @override
  Future<bool> isWatched(int movieId) async {
    final watched = await getWatchedMovieIds();
    return watched.contains(movieId);
  }

  @override
  Future<bool> isInWatchlist(int movieId) async {
    final watchlist = await getWatchlistMovieIds();
    return watchlist.contains(movieId);
  }
}
