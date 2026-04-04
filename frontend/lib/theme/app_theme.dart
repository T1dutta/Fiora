import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.surface, // Sand/Beige base
      textTheme: GoogleFonts.manropeTextTheme().copyWith(
        displayLarge: GoogleFonts.manrope(
          fontSize: 56, // 3.5rem display-lg
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontSize: 28, // 1.75rem headline-md
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 16, // 1rem body-lg
          height: 1.6,
          color: AppColors.onSurface,
        ),
        labelLarge: GoogleFonts.manrope(
          fontSize: 12, // 0.75rem label-md
          fontWeight: FontWeight.w600,
          letterSpacing: 0.05 * 12,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary, // Sage
        secondary: AppColors.secondary, // Terracotta
        tertiary: AppColors.tertiary, // Charcoal
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
      ),
    );
  }
}
