import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_clean_app/data/repositories/movie_repository_impl.dart';
import 'package:flutter_clean_app/data/datasources/movie_remote_data_source.dart';
import 'package:flutter_clean_app/data/datasources/movie_local_data_source.dart';
import 'package:flutter_clean_app/core/network/network_info.dart';
import 'package:flutter_clean_app/domain/entities/movie.dart';
import 'package:flutter_clean_app/data/models/movie_model.dart';
import 'package:dartz/dartz.dart';

class MockRemoteDataSource extends Mock implements MovieRemoteDataSource {
  @override
  Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    return [
      const MovieModel(
        id: 1,
        title: 'Test Movie',
        overview: 'Overview',
        posterPath: '/path.jpg',
        releaseDate: '2023-01-01',
        rating: 8.0,
      )
    ];
  }
}

class MockLocalDataSource extends Mock implements MovieLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {
  @override
  Future<bool> get isConnected => Future.value(true);
}

void main() {
  late MovieRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = MovieRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  test('should return movies when call to remote data source is successful', () async {
    // act
    final result = await repository.getMovies();

    // assert
    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Should not return failure'),
      (movies) {
        expect(movies.length, 1);
        expect(movies.first.title, 'Test Movie');
      },
    );
  });
}
