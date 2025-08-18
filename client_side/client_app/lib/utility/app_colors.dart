import 'package:flutter/material.dart';

/// Premium Color Scheme for Top 1% Apps
/// Inspired by brands like Apple, Netflix, Instagram, and Spotify
class AppColors {
  // Primary Brand Colors - Deep Blue Gradient (Premium feel)
  static const Color primary = Color(0xFF1A1D29);
  static const Color primaryLight = Color(0xFF252A3A);
  static const Color primaryDark = Color(0xFF0F1419);

  // Secondary Colors - Elegant Purple/Blue Gradient
  static const Color secondary = Color(0xFF6366F1);
  static const Color secondaryLight = Color(0xFF8B5CF6);
  static const Color secondaryDark = Color(0xFF4F46E5);

  // Accent Colors - Premium Gold/Orange
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFF8A65);
  static const Color accentDark = Color(0xFFE64A19);

  // Success Colors - Modern Green
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  // Error Colors - Vibrant Red
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  // Warning Colors - Premium Amber
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  // Background Colors - Dark Mode First
  static const Color background = Color(0xFF0F1419);
  static const Color backgroundLight = Color(0xFF1A1D29);
  static const Color backgroundCard = Color(0xFF252A3A);
  static const Color backgroundElevated = Color(0xFF2D3748);

  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1D29);
  static const Color surfaceElevated = Color(0xFFF8FAFC);
  static const Color surfaceContainer = Color(0xFFF1F5F9);

  // Text Colors - High Contrast
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textTertiary = Color(0xFF718096);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF7FAFC);
  static const Color borderDark = Color(0xFFCBD5E0);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowDark = Color(0x26000000);

  // Gradient Collections
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0F1419), Color(0xFF1A1D29)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Premium Glassmorphism Colors
  static Color glassPrimary = const Color(0xFFFFFFFF).withOpacity(0.1);
  static Color glassSecondary = const Color(0xFF6366F1).withOpacity(0.1);
  static Color glassAccent = const Color(0xFFFF6B35).withOpacity(0.1);

  // Status Colors with Transparency
  static Color inStock = const Color(0xFF10B981).withOpacity(0.1);
  static Color outOfStock = const Color(0xFFEF4444).withOpacity(0.1);
  static Color newProduct = const Color(0xFF6366F1).withOpacity(0.1);
  static Color sale = const Color(0xFFFF6B35).withOpacity(0.1);

  // Social Media Inspired Colors
  static const Color instagram = Color(0xFFE4405F);
  static const Color facebook = Color(0xFF1877F2);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color whatsapp = Color(0xFF25D366);

  // Material 3 Inspired Neutral Palette
  static const Color neutral10 = Color(0xFF1A1C1E);
  static const Color neutral20 = Color(0xFF2F3033);
  static const Color neutral30 = Color(0xFF46474A);
  static const Color neutral40 = Color(0xFF5E5E62);
  static const Color neutral50 = Color(0xFF76777A);
  static const Color neutral60 = Color(0xFF909094);
  static const Color neutral70 = Color(0xFFABABAF);
  static const Color neutral80 = Color(0xFFC7C7CB);
  static const Color neutral90 = Color(0xFFE3E3E7);
  static const Color neutral95 = Color(0xFFF1F1F5);
  static const Color neutral99 = Color(0xFFFFFBFF);

  // Theme-based getters for easy switching
  static bool _isDarkMode = false;

  static void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
  }

  static Color get adaptiveBackground => _isDarkMode ? background : surface;
  static Color get adaptiveText => _isDarkMode ? textInverse : textPrimary;
  static Color get adaptiveSurface => _isDarkMode ? surfaceDark : surface;
  static Color get adaptiveBorder => _isDarkMode ? neutral40 : border;

  // Dynamic accent color based on key (category/brand)
  static Color dynamicAccent(String? key) {
    if (key == null || key.isEmpty) return secondary;
    final palette = [
      const Color(0xFF667eea), // Indigo
      const Color(0xFF4ECDC4), // Teal
      const Color(0xFFFF6B6B), // Coral
      const Color(0xFF45B7D1), // Blue
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFFF8A65), // Orange
      const Color(0xFF10B981), // Green
    ];
    final idx = key.hashCode.abs() % palette.length;
    return palette[idx];
  }
}

/// Extension for easy color access
extension AppColorsExtension on BuildContext {
  AppColors get colors => AppColors();
}

/// Premium Box Shadow Styles
class AppShadows {
  static List<BoxShadow> get small => [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get medium => [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get large => [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get premium => [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: AppColors.shadowDark,
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get glassmorphism => [
        BoxShadow(
          color: Colors.white.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}

/// Premium Border Radius Styles
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 9999.0;

  static BorderRadius get xsRadius => BorderRadius.circular(xs);
  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get xxlRadius => BorderRadius.circular(xxl);
  static BorderRadius get fullRadius => BorderRadius.circular(full);
}
