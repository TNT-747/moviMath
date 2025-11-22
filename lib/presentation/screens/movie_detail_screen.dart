import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/api_constants.dart';
import '../bloc/search/movie_search_bloc.dart';
import '../bloc/watchlist/watchlist_bloc.dart';

/// Movie detail screen showing full movie information
class MovieDetailScreen extends StatelessWidget {
  final int movieId;

  const MovieDetailScreen({
    super.key,
    required this.movieId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MovieSearchBloc, MovieSearchState>(
        builder: (context, searchState) {
          if (searchState is! SearchLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final movie = searchState.movies.firstWhere(
            (m) => m.id == movieId,
            orElse: () => searchState.movies.first,
          );

          final posterUrl = ApiConstants.getPosterUrl(movie.posterPath);

          return BlocBuilder<WatchlistBloc, WatchlistState>(
            builder: (context, watchlistState) {
              final isWatched = watchlistState.watchedIds.contains(movieId);
              final isInWatchlist = watchlistState.watchlistIds.contains(movieId);

              return CustomScrollView(
                slivers: [
                  // App Bar with poster background
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        movie.title,
                        style: const TextStyle(
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3.0,
                              color: Colors.black87,
                            ),
                          ],
                        ),
                      ),
                      background: posterUrl.isNotEmpty
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: posterUrl,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.7),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.movie, size: 100),
                            ),
                    ),
                  ),

                  // Movie details
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rating and release date
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 24),
                              const SizedBox(width: 4),
                              Text(
                                movie.rating.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(width: 16),
                              if (movie.releaseDate != null)
                                Text(
                                  movie.releaseDate!,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.grey,
                                      ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () {
                                    context.read<WatchlistBloc>().add(ToggleWatchedEvent(movieId));
                                  },
                                  icon: Icon(isWatched ? Icons.check : Icons.visibility),
                                  label: Text(isWatched ? 'Watched' : 'Mark as Watched'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: isWatched ? Colors.green : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: () {
                                    context.read<WatchlistBloc>().add(ToggleWatchlistEvent(movieId));
                                  },
                                  icon: Icon(isInWatchlist ? Icons.bookmark : Icons.bookmark_border),
                                  label: Text(isInWatchlist ? 'In Watchlist' : 'Add to Watchlist'),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Watch Trailer Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final query = Uri.encodeComponent('${movie.title} trailer');
                                final url = Uri.parse('https://www.youtube.com/results?search_query=$query');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },
                              icon: const Icon(Icons.play_circle_outline),
                              label: const Text('Watch Trailer'),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Overview
                          Text(
                            'Overview',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            movie.overview,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
