import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/usecases/get_movies.dart';
import '../../../domain/usecases/search_movies.dart';

// Events
abstract class MovieSearchEvent extends Equatable {
  const MovieSearchEvent();

  @override
  List<Object> get props => [];
}

class LoadPopularMovies extends MovieSearchEvent {}

class SearchQueryChanged extends MovieSearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

// States
abstract class MovieSearchState extends Equatable {
  const MovieSearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends MovieSearchState {}

class SearchLoading extends MovieSearchState {}

class SearchLoaded extends MovieSearchState {
  final List<Movie> movies;
  final bool isSearchResult;

  const SearchLoaded({
    required this.movies,
    this.isSearchResult = false,
  });

  @override
  List<Object> get props => [movies, isSearchResult];
}

class SearchError extends MovieSearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class MovieSearchBloc extends Bloc<MovieSearchEvent, MovieSearchState> {
  final GetMovies getMovies;
  final SearchMovies searchMovies;

  MovieSearchBloc({
    required this.getMovies,
    required this.searchMovies,
  }) : super(SearchInitial()) {
    on<LoadPopularMovies>(_onLoadPopularMovies);
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: (events, mapper) {
        return events
            .debounceTime(const Duration(milliseconds: 300))
            .switchMap(mapper);
      },
    );
  }

  Future<void> _onLoadPopularMovies(
    LoadPopularMovies event,
    Emitter<MovieSearchState> emit,
  ) async {
    emit(SearchLoading());

    final result = await getMovies(NoParams());

    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (movies) => emit(SearchLoaded(movies: movies)),
    );
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<MovieSearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(LoadPopularMovies());
      return;
    }

    emit(SearchLoading());

    final result = await searchMovies(SearchMoviesParams(query: event.query));

    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (movies) => emit(SearchLoaded(movies: movies, isSearchResult: true)),
    );
  }
}
