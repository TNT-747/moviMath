import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/movie_local_data_source.dart';
import '../../data/datasources/movie_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/get_movie_details.dart';
import '../../domain/usecases/get_movies.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/search_movies.dart';
import '../../domain/usecases/signup.dart';
import '../../domain/usecases/toggle_watched.dart';
import '../../domain/usecases/toggle_watchlist.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/search/movie_search_bloc.dart';
import '../../presentation/bloc/watchlist/watchlist_bloc.dart';
import '../../presentation/cubit/theme_cubit.dart';
import '../constants/api_constants.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';

/// Service Locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> init() async {
  // Initialize Hive
  await Hive.initFlutter();
  
  // Open Hive boxes
  await Hive.openBox(AppConstants.settingsBox);
  await Hive.openBox(AppConstants.cacheBox);
  await Hive.openBox(AppConstants.userPreferencesBox);
  
  //! External Dependencies
  // DioClient for HTTP requests
  sl.registerLazySingleton<DioClient>(() => DioClient());
  
  // Connectivity for network checking
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  
  // NetworkInfo for checking internet connection
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  
  // Hive boxes
  sl.registerLazySingleton<Box>(() => Hive.box(AppConstants.cacheBox), instanceName: 'cacheBox');
  sl.registerLazySingleton<Box>(() => Hive.box(AppConstants.settingsBox), instanceName: 'settingsBox');
  sl.registerLazySingleton<Box>(() => Hive.box(AppConstants.userPreferencesBox), instanceName: 'userPreferencesBox');
  
  //! Data Sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(box: sl(instanceName: 'cacheBox')),
  );
  sl.registerLazySingleton<MovieLocalDataSource>(
    () => MovieLocalDataSourceImpl(box: sl(instanceName: 'userPreferencesBox')),
  );
  sl.registerLazySingleton<MovieRemoteDataSource>(
    () => MovieRemoteDataSourceImpl(client: sl()),
  );
  
  //! Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  //! Use Cases
  // Auth
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Signup(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  
  // Movies
  sl.registerLazySingleton(() => GetMovies(sl()));
  sl.registerLazySingleton(() => SearchMovies(sl()));
  sl.registerLazySingleton(() => GetMovieDetails(sl()));
  sl.registerLazySingleton(() => ToggleWatched(sl()));
  sl.registerLazySingleton(() => ToggleWatchlist(sl()));
  
  //! BLoCs & Cubits
  sl.registerFactory(
    () => AuthBloc(
      login: sl(),
      signup: sl(),
      logout: sl(),
      checkAuthStatus: sl(),
    ),
  );
  
  sl.registerFactory(
    () => MovieSearchBloc(
      getMovies: sl(),
      searchMovies: sl(),
    ),
  );
  
  sl.registerFactory(
    () => WatchlistBloc(
      toggleWatched: sl(),
      toggleWatchlist: sl(),
      localDataSource: sl(),
      movieRepository: sl(),
    ),
  );
  
  sl.registerFactory(
    () => ThemeCubit(box: sl(instanceName: 'settingsBox')),
  );
}
