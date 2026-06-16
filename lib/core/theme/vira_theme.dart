import 'package:flutter/material.dart';
import 'vira_colors.dart';
import 'vira_type.dart';
import 'vira_space.dart';

/// Single source of truth for Flutter's ThemeData. All three apps
/// (Rider/Courier/Dispatch) consume this same theme — role differentiation
/// happens in navigation and content, never in color/type, so the brand
/// stays unmistakably VIRA regardless of which surface you're looking at.
class ViraTheme {
  ViraTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: ViraColors.obsidian,
      primaryColor: ViraColors.crimson,

      colorScheme: const ColorScheme.dark(
        primary: ViraColors.crimson,
        secondary: ViraColors.cyan,
        surface: ViraColors.obsidianSurface1,
        error: ViraColors.crimson,
        onPrimary: ViraColors.platinum,
        onSecondary: ViraColors.obsidian,
        onSurface: ViraColors.platinum,
        onError: ViraColors.platinum,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: ViraColors.obsidian,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: ViraColors.platinum),
        titleTextStyle: ViraType.h3,
      ),

      cardTheme: CardThemeData(
        color: ViraColors.obsidianSurface1,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ViraRadius.lg),
          side: const BorderSide(color: ViraColors.platinum10, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      dividerTheme: const DividerThemeData(
        color: ViraColors.platinum10,
        thickness: 1,
        space: 1,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ViraColors.crimson,
          foregroundColor: ViraColors.platinum,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: ViraSpace.xxl,
            vertical: ViraSpace.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ViraRadius.md),
          ),
          textStyle: ViraType.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ViraColors.platinum,
          side: const BorderSide(color: ViraColors.platinum10),
          padding: const EdgeInsets.symmetric(
            horizontal: ViraSpace.xxl,
            vertical: ViraSpace.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ViraRadius.md),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ViraColors.obsidianSurface2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ViraSpace.lg,
          vertical: ViraSpace.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ViraRadius.md),
          borderSide: const BorderSide(color: ViraColors.platinum10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ViraRadius.md),
          borderSide: const BorderSide(color: ViraColors.platinum10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ViraRadius.md),
          borderSide: const BorderSide(color: ViraColors.cyan, width: 1.5),
        ),
        hintStyle: ViraType.body.copyWith(color: ViraColors.platinum30),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ViraColors.obsidianSurface1,
        selectedItemColor: ViraColors.crimson,
        unselectedItemColor: ViraColors.platinum30,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      textTheme: base.textTheme.copyWith(
        displayLarge: ViraType.displayLarge,
        headlineLarge: ViraType.h1,
        headlineMedium: ViraType.h2,
        headlineSmall: ViraType.h3,
        bodyLarge: ViraType.bodyLarge,
        bodyMedium: ViraType.body,
        bodySmall: ViraType.bodySmall,
      ),

      iconTheme: const IconThemeData(color: ViraColors.platinum),
    );
  }
}
