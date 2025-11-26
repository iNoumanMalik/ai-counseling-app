import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:semester_project/config/colors.dart';

/// App theme configuration
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primarySkyBlue,
        secondary: AppColors.primaryMintGreen,
        tertiary: AppColors.softAqua,
        background: AppColors.lightGray100,
        surface: AppColors.white,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.dark900,
        onBackground: AppColors.dark900,
        onSurface: AppColors.dark900,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.lightGray100,
      // fontFamily: 'Inter', // Uncomment after adding fonts to assets/fonts/
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          // fontFamily: 'Poppins', // Uncomment after adding fonts
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.dark900,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          // fontFamily: 'Poppins', // Uncomment after adding fonts
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.dark900,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          // fontFamily: 'Poppins', // Uncomment after adding fonts
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.dark900,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          // fontFamily: 'Poppins', // Uncomment after adding fonts
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.dark900,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          // fontFamily: 'Poppins', // Uncomment after adding fonts
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.dark900,
          height: 1.4,
        ),
        headlineSmall: TextStyle(
          // fontFamily: 'Inter', // Uncomment after adding fonts
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.dark900,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          // fontFamily: 'Inter', // Uncomment after adding fonts
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.dark900,
          height: 1.5,
        ),
        titleMedium: TextStyle(
          // fontFamily: 'Inter', // Uncomment after adding fonts
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.dark900,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          // fontFamily: 'Inter', // Uncomment after adding fonts
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.lightGray300,
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          // fontFamily: 'Inter', // Uncomment after adding fonts
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.dark900,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          // fontFamily: 'Inter', // Uncomment after adding fonts
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.dark900,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          // fontFamily: 'Inter', // Uncomment after adding fonts
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.lightGray300,
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
          color: AppColors.lightGray300,
          height: 1.5,
        ),
        labelSmall: TextStyle(
          // fontFamily: 'Inter', // Uncomment after adding fonts
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.lightGray300,
          height: 1.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.dark900,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          // fontFamily: 'Poppins', // Uncomment after adding fonts
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.dark900,
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
          backgroundColor: AppColors.primarySkyBlue,
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
          side: const BorderSide(color: AppColors.primarySkyBlue, width: 2),
          foregroundColor: AppColors.primarySkyBlue,
          textStyle: const TextStyle(
            // fontFamily: 'Inter', // Uncomment after adding fonts
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primarySkyBlue,
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
          borderSide: const BorderSide(color: AppColors.primarySkyBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: AppColors.primarySkyBlue,
        foregroundColor: AppColors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primarySkyBlue,
        unselectedItemColor: AppColors.lightGray300,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
