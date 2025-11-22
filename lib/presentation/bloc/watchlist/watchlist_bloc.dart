import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/movie.dart';
import '../../../domain/usecases/toggle_watched.dart';
import '../../../domain/usecases/toggle_watchlist.dart';
import '../../../domain/repositories/movie_repository.dart';
import '../../../data/datasources/movie_local_data_source.dart';

// Events
abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object> get props => [];
}

class LoadUserLists extends WatchlistEvent {}

class ToggleWatchedEvent extends WatchlistEvent {
  final int movieId;

  const ToggleWatchedEvent(this.movieId);

  @override
  List<Object> get props => [movieId];
}

class ToggleWatchlistEvent extends WatchlistEvent {
  final int movieId;

  const ToggleWatchlistEvent(this.movieId);

  @override
  List<Object> get props => [movieId];
}

// States
class WatchlistState extends Equatable {
  final Set<int> watchedIds;
  final Set<int> watchlistIds;
  final List<Movie> watchedMovies;
  final List<Movie> watchlistMovies;
  final String? errorMessage;

  const WatchlistState({
    this.watchedIds = const {},
    this.watchlistIds = const {},
    this.watchedMovies = const [],
    this.watchlistMovies = const [],
    this.errorMessage,
  });

  WatchlistState copyWith({
    Set<int>? watchedIds,
    Set<int>? watchlistIds,
    List<Movie>? watchedMovies,
    List<Movie>? watchlistMovies,
    String? errorMessage,
  }) {
    return WatchlistState(
      watchedIds: watchedIds ?? this.watchedIds,
      watchlistIds: watchlistIds ?? this.watchlistIds,
      watchedMovies: watchedMovies ?? this.watchedMovies,
      watchlistMovies: watchlistMovies ?? this.watchlistMovies,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [watchedIds, watchlistIds, watchedMovies, watchlistMovies, errorMessage];
}

// BLoC
class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final ToggleWatched toggleWatched;
  final ToggleWatchlist toggleWatchlist;
  final MovieLocalDataSource localDataSource;
  final MovieRepository movieRepository;

  WatchlistBloc({
    required this.toggleWatched,
    required this.toggleWatchlist,
    required this.localDataSource,
    required this.movieRepository,
  }) : super(const WatchlistState()) {
    on<LoadUserLists>(_onLoadUserLists);
    on<ToggleWatchedEvent>(_onToggleWatched);
    on<ToggleWatchlistEvent>(_onToggleWatchlist);
  }

  Future<void> _onLoadUserLists(
    LoadUserLists event,
    Emitter<WatchlistState> emit,
  ) async {
    try {
      // Load IDs first for quick access
      final watchedIds = await localDataSource.getWatchedMovieIds();
      final watchlistIds = await localDataSource.getWatchlistMovieIds();
      
      emit(state.copyWith(
        watchedIds: watchedIds,
        watchlistIds: watchlistIds,
      ));

      // Then load full movies
      final watchedResult = await movieRepository.getWatchedMovies();
      final watchlistResult = await movieRepository.getWatchlistMovies();

      watchedResult.fold(
        (failure) => emit(state.copyWith(errorMessage: failure.message)),
        (movies) => emit(state.copyWith(watchedMovies: movies)),
      );

      watchlistResult.fold(
        (failure) => emit(state.copyWith(errorMessage: failure.message)),
        (movies) => emit(state.copyWith(watchlistMovies: movies)),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to load user lists'));
    }
  }

  Future<void> _onToggleWatched(
    ToggleWatchedEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    final result = await toggleWatched(ToggleWatchedParams(movieId: event.movieId));

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        add(LoadUserLists()); // Reload to update lists
      },
    );
  }

  Future<void> _onToggleWatchlist(
    ToggleWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    final result = await toggleWatchlist(ToggleWatchlistParams(movieId: event.movieId));

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        add(LoadUserLists()); // Reload to update lists
      },
    );
  }
}
