import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

/// States for theme mode
class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

/// Cubit to manage theme mode
class ThemeCubit extends Cubit<ThemeState> {
  final Box box;
  static const String _themeModeKey = 'theme_mode';

  ThemeCubit({required this.box}) : super(ThemeState(_getInitialThemeMode(box)));

  /// Get initial theme mode from storage
  static ThemeMode _getInitialThemeMode(Box box) {
    final savedMode = box.get(_themeModeKey, defaultValue: 'system') as String;
    switch (savedMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Toggle between light and dark modes
  void toggleTheme() {
    final newMode = state.themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    _setThemeMode(newMode);
  }

  /// Set specific theme mode
  void setThemeMode(ThemeMode mode) {
    _setThemeMode(mode);
  }

  /// Internal method to set and persist theme mode
  void _setThemeMode(ThemeMode mode) {
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    box.put(_themeModeKey, modeString);
    emit(ThemeState(mode));
  }
}
