import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/movie_model.dart';

/// Abstract class for movie remote data source
abstract class MovieRemoteDataSource {
  /// Get popular movies from TMDB API
  Future<List<MovieModel>> getPopularMovies({int page = 1});
  
  /// Search movies from TMDB API
  Future<List<MovieModel>> searchMovies(String query);
  
  /// Get movie details by ID from TMDB API
  Future<MovieModel> getMovieById(int id);
}

/// Implementation of MovieRemoteDataSource using TMDB API
class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final DioClient client;

  MovieRemoteDataSourceImpl({required this.client});

  @override
  Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    try {
      final response = await client.get(
        ApiConstants.popularMovies,
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List;
        return results.map((json) => MovieModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          'Failed to load movies',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<MovieModel>> searchMovies(String query) async {
    try {
      final response = await client.get(
        ApiConstants.searchMovies,
        queryParameters: {'query': query},
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List;
        return results.map((json) => MovieModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          'Failed to search movies',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<MovieModel> getMovieById(int id) async {
    try {
      final response = await client.get(
        '${ApiConstants.movieDetails}/$id',
      );

      if (response.statusCode == 200) {
        return MovieModel.fromJson(response.data);
      } else {
        throw ServerException(
          'Failed to load movie details',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Handle DioException and convert to appropriate custom exception
  AppException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return const ConnectionException('Connection timeout - please check your internet connection');
      
      case DioExceptionType.sendTimeout:
        return const TimeoutException('Send timeout - request took too long');
      
      case DioExceptionType.receiveTimeout:
        return const TimeoutException('Receive timeout - server took too long to respond');
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 400:
            return ServerException('Bad request', statusCode);
          case 401:
            return ServerException('Unauthorized - invalid API key', statusCode);
          case 404:
            return ServerException('Resource not found', statusCode);
          case 500:
            return ServerException('Internal server error', statusCode);
          case 503:
            return ServerException('Service unavailable', statusCode);
          default:
            return ServerException(
              'Server error: ${e.response?.statusMessage ?? 'Unknown error'}',
              statusCode,
            );
        }
      
      case DioExceptionType.cancel:
        return const NetworkException('Request was cancelled');
      
      case DioExceptionType.connectionError:
        return const ConnectionException('No internet connection');
      
      case DioExceptionType.badCertificate:
        return const NetworkException('Bad certificate');
      
      case DioExceptionType.unknown:
        return NetworkException('Network error: ${e.message}');
    }
  }
}
