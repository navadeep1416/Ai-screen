import 'package:flutter/material.dart';

/// Cyberpunk Neon Color Palette
class AppColors {
  AppColors._();

  // Core backgrounds
  static const Color background = Color(0xFF0d0d1a);
  static const Color surface = Color(0xFF120d1f);
  static const Color card = Color(0xFF1a1030);
  static const Color border = Color(0xFF2a1f45);

  // Neon accents
  static const Color primaryPurple = Color(0xFF8b5cf6);
  static const Color primaryPink = Color(0xFFec4899);
  static const Color accentCyan = Color(0xFF06b6d4);
  static const Color accentGreen = Color(0xFF10b981);
  static const Color accentYellow = Color(0xFFeab308);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPink, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF571bc1), Color(0xFF8b5cf6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text colors
  static const Color textPrimary = Color(0xFFffffff);
  static const Color textSecondary = Color(0xFFa0a0b0);
  static const Color textMuted = Color(0xFF6b6b80);

  // Status colors
  static const Color success = Color(0xFF10b981);
  static const Color warning = Color(0xFFeab308);
  static const Color error = Color(0xFFef4444);

  // Glass effect colors
  static const Color glassBackground = Color(0xFF1A2026);
  static const Color glassBorder = Color(0xFF524251);
}

/// Typography styles
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.02,
  );

  static const TextStyle headingMed = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );

  // Gradient text style
  static ShaderCallback gradientShader = (bounds) {
    return AppColors.primaryGradient.createShader(bounds);
  };
}

/// Glassmorphism decoration
class AppDecorations {
  AppDecorations._();

  static BoxDecoration glassCard({
    Color? backgroundColor,
    Color? borderColor,
    double borderRadius = 12,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.glassBackground.withOpacity(0.6),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppColors.glassBorder.withOpacity(0.3),
      ),
    );
  }

  static BoxDecoration neonButton({
    LinearGradient? gradient,
    double borderRadius = 28,
  }) {
    return BoxDecoration(
      gradient: gradient ?? AppColors.primaryGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryPink.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration neonGlow({
    required Color color,
    double blurRadius = 15,
    double spreadRadius = 5,
  }) {
    return BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
      ],
    );
  }

  static BoxDecoration overlayContainer() {
    return BoxDecoration(
      color: AppColors.background.withOpacity(0.95),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryPurple.withOpacity(0.15),
          blurRadius: 30,
          spreadRadius: 2,
        ),
      ],
    );
  }
}

/// Main theme data
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryPurple,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryPurple,
        secondary: AppColors.primaryPink,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTypography.headingMed,
      ),
      textTheme: const TextTheme(
        headlineLarge: AppTypography.headingLarge,
        headlineMedium: AppTypography.headingMed,
        bodyMedium: AppTypography.bodyText,
        bodySmall: AppTypography.caption,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryPink),
        ),
        labelStyle: const TextStyle(color: AppColors.textMuted),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0D0720),
        selectedItemColor: Color(0xFFFBABFF),
        unselectedItemColor: AppColors.textSecondary,
      ),
    );
  }
}