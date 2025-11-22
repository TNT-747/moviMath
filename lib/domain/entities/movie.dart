import 'package:equatable/equatable.dart';

/// Movie entity representing a movie in the domain layer
class Movie extends Equatable {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? releaseDate;
  final double rating;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.releaseDate,
    required this.rating,
  });

  @override
  List<Object?> get props => [id, title, overview, posterPath, releaseDate, rating];
}
