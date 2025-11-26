import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

/// App theme configuration
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        background: AppColors.background,
        surface: AppColors.white,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.darkText,
        onBackground: AppColors.darkText,
        onSurface: AppColors.darkText,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      // fontFamily: 'Inter', // Uncomment after adding fonts to assets/fonts/
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          // fontFamily: 'Poppins', // Uncomment after adding fonts
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          // fontFamily: 'Poppins', // Uncomment after adding fonts
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          // fontFamily: 'Poppins', // Uncomment after adding fonts
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          // fontFamily: 'Poppins', // Uncomment after adding fonts
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          // fontFamily: 'Poppins', // Uncomment after adding fonts
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
          height: 1.4,
        ),
        headlineSmall: TextStyle(
          // fontFamily: 'Inter', // Uncomment after adding fonts
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          // fontFamily: 'Inter', // Uncomment after adding fonts
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
          height: 1.5,
        ),
        titleMedium: TextStyle(
          // fontFamily: 'Inter', // Uncomment after adding fonts
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkText,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          // fontFamily: 'Inter', // Uncomment after adding fonts
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.mediumGray,
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          // fontFamily: 'Inter', // Uncomment after adding fonts
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.darkText,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          // fontFamily: 'Inter', // Uncomment after adding fonts
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.darkText,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          // fontFamily: 'Inter', // Uncomment after adding fonts
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.mediumGray,
          height: 1.6,
        ),
        labelLarge: TextStyle(
          // fontFamily: 'Inter', // Uncomment after adding fonts
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
          height: 1.5,
        ),
        labelMedium: TextStyle(
          // fontFamily: 'Inter', // Uncomment after adding fonts
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.mediumGray,
          height: 1.5,
        ),
        labelSmall: TextStyle(
          // fontFamily: 'Inter', // Uncomment after adding fonts
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.mediumGray,
          height: 1.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkText,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          // fontFamily: 'Poppins', // Uncomment after adding fonts
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: AppColors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          textStyle: const TextStyle(
            // fontFamily: 'Inter', // Uncomment after adding fonts
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: AppColors.primary, width: 2),
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            // fontFamily: 'Inter', // Uncomment after adding fonts
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            // fontFamily: 'Inter', // Uncomment after adding fonts
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mediumGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}

