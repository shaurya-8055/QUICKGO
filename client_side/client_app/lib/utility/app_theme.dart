import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'app_colors.dart';

/// Premium App Theme - Top 1% Quality
/// Inspired by Apple, Netflix, Instagram, and premium e-commerce apps
class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        // Color Scheme
        colorScheme: ColorScheme.light(
          primary: AppColors.secondary,
          primaryContainer: AppColors.secondaryLight,
          onPrimary: AppColors.textOnPrimary,
          secondary: AppColors.accent,
          secondaryContainer: AppColors.accentLight,
          onSecondary: AppColors.textOnPrimary,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          background: AppColors.surface,
          onBackground: AppColors.textPrimary,
          error: AppColors.error,
          onError: AppColors.textOnPrimary,
          outline: AppColors.border,
          surfaceVariant: AppColors.surfaceContainer,
          onSurfaceVariant: AppColors.textSecondary,
        ),

        // App Bar Theme
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: AppColors.shadow,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
          iconTheme: IconThemeData(
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),

        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.textOnPrimary,
            elevation: 4,
            shadowColor: AppColors.secondary.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.lgRadius,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.secondary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.25,
            ),
          ),
        ),

        // Text Theme
        textTheme: TextTheme(
          displayLarge: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            height: 1.2,
          ),
          displayMedium: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            height: 1.3,
          ),
          displaySmall: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.25,
            height: 1.3,
          ),
          headlineMedium: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.4,
          ),
          headlineSmall: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.4,
          ),
          titleLarge: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
            height: 1.5,
          ),
          bodyLarge: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.15,
            height: 1.6,
          ),
          bodyMedium: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
            height: 1.5,
          ),
          bodySmall: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
            height: 1.4,
          ),
        ),

        // Scaffold Background Color
        scaffoldBackgroundColor: AppColors.surface,

        // Icon Theme
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),

        // Card Theme
      cardTheme: CardThemeData(
  surfaceTintColor: AppColors.surface,
  shadowColor: AppColors.shadow,
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: AppRadius.mdRadius,
  ),
  margin: const EdgeInsets.all(8),
),


        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceContainer,
          border: OutlineInputBorder(
            borderRadius: AppRadius.mdRadius,
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdRadius,
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdRadius,
            borderSide: BorderSide(color: AppColors.secondary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 16,
          ),
        ),

        // Font Family (you can add your custom font here)
        fontFamily: 'SF Pro Display', // iOS-like font for premium feel
      );

  // Legacy support - keeping old theme structure for compatibility
  static ThemeData lightAppTheme = lightTheme;

  // New Dark Theme for premium experience with high contrast text
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        // Color Scheme with high contrast
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B5CF6),
          primaryContainer: Color(0xFF6D28D9),
          onPrimary: Colors.white,
          secondary: Color(0xFFFF6B35),
          secondaryContainer: Color(0xFFEA580C),
          onSecondary: Colors.white,
          surface: Color(0xFF1A1D29),
          onSurface: Color(0xFFFFFFFF), // High contrast white
          background: Color(0xFF0F1419),
          onBackground: Color(0xFFFFFFFF), // High contrast white
          error: Color(0xFFEF4444),
          onError: Colors.white,
          outline: Color(0xFF4A5568),
          surfaceVariant: Color(0xFF252A3A),
          onSurfaceVariant: Color(0xFFE2E8F0), // Light gray for secondary text
        ),

        scaffoldBackgroundColor: const Color(0xFF0F1419),

        // App Bar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F1419),
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: Colors.black26,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
            size: 24,
          ),
        ),

        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: const Color(0xFF8B5CF6).withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.lgRadius,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF8B5CF6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.25,
            ),
          ),
        ),

        // High Contrast Text Theme
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            height: 1.2,
          ),
          displayMedium: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            height: 1.3,
          ),
          displaySmall: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.25,
            height: 1.3,
          ),
          headlineMedium: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.4,
          ),
          headlineSmall: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.4,
          ),
          titleLarge: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
            height: 1.5,
          ),
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.15,
            height: 1.6,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFFE2E8F0), // Light gray for secondary text
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
            height: 1.5,
          ),
          bodySmall: TextStyle(
            color: Color(0xFFCBD5E0), // Medium gray for tertiary text
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
            height: 1.4,
          ),
        ),

        // Icon Theme
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),

        // Card Theme
        cardTheme: CardTheme(
          color: const Color(0xFF1A1D29),
          shadowColor: Colors.black.withOpacity(0.3),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdRadius,
          ),
          margin: const EdgeInsets.all(8),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF252A3A),
          border: OutlineInputBorder(
            borderRadius: AppRadius.mdRadius,
            borderSide: const BorderSide(color: Color(0xFF4A5568)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdRadius,
            borderSide: const BorderSide(color: Color(0xFF4A5568)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdRadius,
            borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: const TextStyle(
            color: Color(0xFFCBD5E0),
            fontSize: 16,
          ),
        ),

        // Font Family
        fontFamily: 'SF Pro Display',
      );
}
