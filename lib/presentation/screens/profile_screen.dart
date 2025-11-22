import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/watchlist/watchlist_bloc.dart';
import '../widgets/movie_card.dart';

/// Profile screen showing watched and watchlist movies
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.check), text: 'Watched'),
              Tab(icon: Icon(Icons.bookmark), text: 'Watchlist'),
            ],
          ),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! Authenticated) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // User info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authState.user.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              authState.user.email,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Tabs content
                Expanded(
                  child: BlocBuilder<WatchlistBloc, WatchlistState>(
                    builder: (context, watchlistState) {
                      return TabBarView(
                        children: [
                          // Watched tab
                          _buildMovieGrid(
                            context,
                            watchlistState.watchedMovies,
                            watchlistState.watchedIds,
                            watchlistState.watchlistIds,
                            emptyMessage: 'No watched movies yet',
                          ),

                          // Watchlist tab
                          _buildMovieGrid(
                            context,
                            watchlistState.watchlistMovies,
                            watchlistState.watchedIds,
                            watchlistState.watchlistIds,
                            emptyMessage: 'Your watchlist is empty',
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMovieGrid(
    BuildContext context,
    List movies,
    Set<int> watchedIds,
    Set<int> watchlistIds, {
    required String emptyMessage,
  }) {
    if (movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.movie_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            final isWatched = watchedIds.contains(movie.id);
            final isInWatchlist = watchlistIds.contains(movie.id);

            return MovieCard(
              movie: movie,
              isWatched: isWatched,
              isInWatchlist: isInWatchlist,
              onTap: () {
                // Navigate to details, but we need to be careful about routing
                // context.push('/details/${movie.id}');
                // For now, let's assume the router handles it
              },
            );
          },
        );
      },
    );
  }
}
