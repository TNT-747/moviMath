/// API Configuration Constants
class ApiConstants {
  // Prevent instantiation
  ApiConstants._();
  
  /// TMDB API Base URL
  static const String baseUrl = 'https://api.themoviedb.org/3';
  
  /// TMDB API Key
  static const String apiKey = '6e9c16766394ec53e52ea4dc83126663';
  
  /// Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  /// API Endpoints
  static const String popularMovies = '/movie/popular';
  static const String movieDetails = '/movie'; // Use: /movie/{id}
  static const String searchMovies = '/search/movie';
  
  /// Image base URLs
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';
  static const String posterSize = 'w500';
  static const String backdropSize = 'w780';
  
  /// Helper methods
  static String getPosterUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl/$posterSize$path';
  }
  
  static String getBackdropUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl/$backdropSize$path';
  }
}

/// App-wide constants
class AppConstants {
  // Prevent instantiation
  AppConstants._();
  
  /// App name
  static const String appName = 'Flutter Clean App';
  
  /// Hive box names
  static const String settingsBox = 'settings_box';
  static const String cacheBox = 'cache_box';
  static const String userPreferencesBox = 'user_preferences';
  
  /// Shared preferences keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String tokenKey = 'auth_token';
  
  /// User preferences keys
  static const String watchedKey = 'watched';
  static const String watchlistKey = 'watchlist';
}
