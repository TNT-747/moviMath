import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/constants/api_constants.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/bloc/search/movie_search_bloc.dart';
import 'presentation/bloc/watchlist/watchlist_bloc.dart';
import 'presentation/cubit/theme_cubit.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/signup_screen.dart';
import 'presentation/screens/movie_detail_screen.dart';
import 'presentation/screens/profile_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<ThemeCubit>(
          create: (_) => di.sl<ThemeCubit>(),
        ),
        BlocProvider<MovieSearchBloc>(
          create: (_) => di.sl<MovieSearchBloc>()..add(LoadPopularMovies()),
        ),
        BlocProvider<WatchlistBloc>(
          create: (_) => di.sl<WatchlistBloc>()..add(LoadUserLists()),
        ),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeState.themeMode,
          routerConfig: _router(context),
        );
      },
    );
  }

  /// GoRouter configuration with auth guards
  GoRouter _router(BuildContext context) {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final isAuthenticated = authState is Authenticated;
        final isAuthRoute = state.matchedLocation == '/login' || 
                           state.matchedLocation == '/signup';

        // If authenticated and trying to access auth routes, redirect to home
        if (isAuthenticated && isAuthRoute) {
          return '/home';
        }

        // If not authenticated and trying to access protected routes, redirect to login
        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }

        // No redirect needed
        return null;
      },
      refreshListenable: GoRouterRefreshStream(
        context.read<AuthBloc>().stream,
      ),
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/details/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return MovieDetailScreen(movieId: id);
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    );
  }
}

/// Helper class to refresh GoRouter when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (AuthState state) {
        notifyListeners();
      },
    );
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
