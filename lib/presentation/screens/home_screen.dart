import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/search/movie_search_bloc.dart';
import '../bloc/watchlist/watchlist_bloc.dart';
import '../widgets/movie_card.dart';
import '../widgets/theme_switch_button.dart';

/// Home screen displaying movie list with responsive grid and search
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.go('/login');
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! Authenticated) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                // AppBar
                SliverAppBar(
                  floating: true,
                  title: const Text('Movies'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.person),
                      onPressed: () => context.push('/profile'),
                      tooltip: 'Profile',
                    ),
                    const ThemeSwitchButton(),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () {
                        context.read<AuthBloc>().add(const AuthLogoutRequested());
                      },
                      tooltip: 'Logout',
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SearchBar(
                        hintText: 'Search movies...',
                        leading: const Icon(Icons.search),
                        onChanged: (query) {
                          context.read<MovieSearchBloc>().add(SearchQueryChanged(query));
                        },
                        elevation: WidgetStateProperty.all(0),
                        backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ),
                  ),
                ),

                // Movie Grid
                BlocBuilder<MovieSearchBloc, MovieSearchState>(
                  builder: (context, searchState) {
                    if (searchState is SearchLoading) {
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (searchState is SearchError) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                'Error: ${searchState.message}',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<MovieSearchBloc>().add(LoadPopularMovies());
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (searchState is SearchLoaded) {
                      if (searchState.movies.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(child: Text('No movies found')),
                        );
                      }

                      return BlocBuilder<WatchlistBloc, WatchlistState>(
                        builder: (context, watchlistState) {
                          return SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverLayoutBuilder(
                              builder: (context, constraints) {
                                // Responsive grid: 2 columns on mobile, 4 on tablet
                                final crossAxisCount = constraints.crossAxisExtent < 600 ? 2 : 4;
                                
                                return SliverGrid(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    childAspectRatio: 0.7,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final movie = searchState.movies[index];
                                      final isWatched = watchlistState.watchedIds.contains(movie.id);
                                      final isInWatchlist = watchlistState.watchlistIds.contains(movie.id);

                                      return MovieCard(
                                        movie: movie,
                                        isWatched: isWatched,
                                        isInWatchlist: isInWatchlist,
                                        onTap: () => context.push('/details/${movie.id}'),
                                      );
                                    },
                                    childCount: searchState.movies.length,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }

                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
