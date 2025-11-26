import 'package:flutter/material.dart';

/// App color palette - Calming and Pastel theme
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF6C63FF); // Soft purple
  static const Color secondary = Color(0xFFA8E6CF); // Mint
  static const Color accent = Color(0xFFFFD3B6); // Peach
  static const Color background = Color(0xFFF7F7FA); // Light gray background
  static const Color darkText = Color(0xFF1E1E2E); // Dark text
  static const Color success = Color(0xFF88E0A8); // Success green

  // Additional colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF0F0F0);
  static const Color mediumGray = Color(0xFF9E9E9E);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFD93D);

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF8B7FFF)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, Color(0xFFB8F5D1)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, Color(0xFFFFFFFF)],
  );

  // Mood colors
  static const Color moodHappy = Color(0xFFFFE066);
  static const Color moodOkay = Color(0xFFFFD3B6);
  static const Color moodSad = Color(0xFFB8B5FF);
  static const Color moodAnxious = Color(0xFFFFB3BA);
  static const Color moodCalm = Color(0xFFA8E6CF);
}

