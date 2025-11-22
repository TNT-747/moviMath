import '../../domain/entities/movie.dart';

/// Movie model for data layer with JSON serialization
class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    required super.overview,
    super.posterPath,
    super.releaseDate,
    required super.rating,
  });

  /// Create MovieModel from JSON
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      releaseDate: json['release_date'] as String?,
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert MovieModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'release_date': releaseDate,
      'rating': rating,
    };
  }

  /// Create MovieModel from Movie entity
  factory MovieModel.fromEntity(Movie movie) {
    return MovieModel(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      posterPath: movie.posterPath,
      releaseDate: movie.releaseDate,
      rating: movie.rating,
    );
  }
}
