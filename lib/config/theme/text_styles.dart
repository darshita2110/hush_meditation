import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  // DISPLAY STYLES
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // HEADING STYLES
  static const TextStyle headingLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // BODY STYLES
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.2,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.2,
  );

  // LABEL STYLES
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );

  // CAPTION STYLES
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
  );

  static const TextStyle captionSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
  );

  // ── Semantic aliases used across screens ──────────────────────────────────
  static const TextStyle h2 = displayMedium;   // 28px bold
  static const TextStyle h3 = displaySmall;    // 24px semi-bold
  static const TextStyle h4 = headingLarge;    // 20px semi-bold
  static const TextStyle h5 = headingSmall;    // 16px semi-bold
  static const TextStyle body1 = bodyLarge;    // 16px regular
  static const TextStyle body2 = bodyMedium;   // 14px regular
}