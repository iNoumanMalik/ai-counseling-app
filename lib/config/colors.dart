import 'package:flutter/material.dart';

/// App color palette - Strict requirements color scheme
class AppColors {
  AppColors._();

  // ========== PRIMARY COLORS ==========
  static const Color primarySkyBlue = Color(0xFF4FACFE); // Primary Sky Blue
  static const Color primaryMintGreen = Color(0xFF00C9A7); // Primary Mint Green
  static const Color deepTherapyBlue = Color(0xFF0C8CE9); // Deep Therapy Blue
  static const Color softAqua = Color(0xFF7BD0C6); // Soft Aqua
  static const Color pastelMint = Color(0xFFD9F7F2); // Pastel Mint

  // Legacy primary (using primarySkyBlue as default)
  static const Color primary = primarySkyBlue;
  static const Color secondary = primaryMintGreen;
  static const Color accent = softAqua;

  // Primary Gradient: #4FACFE → #00F2FE
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
  );

  // ========== SECONDARY COLORS (ACCENTS) ==========
  static const Color lavender = Color(0xFFA78BFA); // Lavender
  static const Color lilac = Color(0xFFC7B8EA); // Lilac
  static const Color purpleMist = Color(0xFFEDE7F6); // Purple Mist

  // Secondary Gradient: #A78BFA → #C1D3FE
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA78BFA), Color(0xFFC1D3FE)],
  );

  // ========== EMOTIONAL COLORS (For mood graph + insights) ==========
  static const Color moodHappy = Color(0xFFFFB86C);
  static const Color moodNeutral = Color(0xFFA0AEC0);
  static const Color moodSad = Color(0xFF7F9CF5);
  static const Color moodStressed = Color(0xFFFCA5A5);
  static const Color moodAnxiety = Color(0xFF81E6D9);
  static const Color moodAngry = Color(0xFFF87171);

  // Legacy mood colors mapping
  static const Color moodOkay = moodNeutral;
  static const Color moodAnxious = moodAnxiety;
  static const Color moodCalm = moodNeutral;

  // ========== NATURAL GREENS (For progress/habits) ==========
  static const Color greenLight = Color(0xFF9AE6B4);
  static const Color greenMedium = Color(0xFF68D391);
  static const Color greenDark = Color(0xFF48BB78);
  static const Color greenVeryDark = Color(0xFF22543D);
  static const Color success = greenMedium;

  // ========== NEUTRALS + BACKGROUND (Light Mode) ==========
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray100 = Color(0xFFF8FAFC);
  static const Color lightGray200 = Color(0xFFEDF2F7);
  static const Color lightGray300 = Color(0xFFCBD5E0);
  
  // Legacy background colors
  static const Color background = lightGray100;
  static const Color lightGray = lightGray200;
  static const Color mediumGray = lightGray300;

  // ========== DARK MODE COLORS ==========
  static const Color dark900 = Color(0xFF0F172A);
  static const Color dark800 = Color(0xFF1E293B);
  static const Color dark700 = Color(0xFF334155);
  static const Color darkText = Color(0xFF94A3B8);

  // ========== GLASSMORPHISM COLORS ==========
  static Color glassWhite = Colors.white.withValues(alpha: 0.2);
  static Color glassSkyBlue = const Color(0xFF4FACFE).withValues(alpha: 0.25);
  static Color glassMintGreen = const Color(0xFF00C9A7).withValues(alpha: 0.2);
  static Color glassLavender = const Color(0xFFA78BFA).withValues(alpha: 0.2);
  static Color glassShadow = Colors.black.withValues(alpha: 0.08);

  // ========== BACKGROUND GRADIENTS ==========
  
  // A. Therapy Sunrise: #4FACFE → #C7D2FE → #E0E7FF
  static const LinearGradient gradientTherapySunrise = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4FACFE),
      Color(0xFFC7D2FE),
      Color(0xFFE0E7FF),
    ],
  );

  // B. Calm Ocean: #00C9A7 → #4FACFE → #C7F9FF
  static const LinearGradient gradientCalmOcean = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00C9A7),
      Color(0xFF4FACFE),
      Color(0xFFC7F9FF),
    ],
  );

  // C. Lavender Peace: #A78BFA → #C7B8EA → #EDE7F6
  static const LinearGradient gradientLavenderPeace = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFA78BFA),
      Color(0xFFC7B8EA),
      Color(0xFFEDE7F6),
    ],
  );

  // D. Soft Mindfulness Pink: #FFE2E2 → #FFD6F2 → #FDF2FA
  static const LinearGradient gradientSoftMindfulnessPink = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFE2E2),
      Color(0xFFFFD6F2),
      Color(0xFFFDF2FA),
    ],
  );

  // Legacy background gradient (using Therapy Sunrise)
  static const LinearGradient backgroundGradient = gradientTherapySunrise;

  // ========== ERROR & WARNING ==========
  static const Color error = Color(0xFFF87171); // Using moodAngry as error
  static const Color warning = Color(0xFFFFB86C); // Using moodHappy as warning

  // ========== 3D AVATAR COLORS ==========
  
  // Skin tones
  static const Color avatarSkinLight = Color(0xFFF8DCCB);
  static const Color avatarSkinMedium = Color(0xFFE2B59C);
  static const Color avatarSkinTan = Color(0xFFC08A67);
  static const Color avatarSkinDark = Color(0xFF8D5631);

  // Hair colors
  static const Color avatarHairBlack = Color(0xFF3A3A3A);
  static const Color avatarHairBrown = Color(0xFF6C4B3C);
  static const Color avatarHairLightBrown = Color(0xFFA57C65);
  static const Color avatarHairBlonde = Color(0xFFD8C3B5);

  // Clothes colors (matching palette)
  static const Color avatarClothAqua = Color(0xFF7BD0C6);
  static const Color avatarClothLavender = Color(0xFFA78BFA);
  static const Color avatarClothWarm = Color(0xFFFFB86C);
  static const Color avatarClothGreen = Color(0xFF68D391);
}
