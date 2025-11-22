import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/theme_cubit.dart';

/// Theme switch button for toggling between light and dark modes
class ThemeSwitchButton extends StatelessWidget {
  const ThemeSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isDark = state.themeMode == ThemeMode.dark;
        
        return IconButton(
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
          ),
          onPressed: () {
            context.read<ThemeCubit>().toggleTheme();
          },
          tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
        );
      },
    );
  }
}
