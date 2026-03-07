import 'package:flutter/material.dart';

class AppColors {

  AppColors._();

  // PRIMARY COLOR PALETTE
  static const Color primary = Color(0xFF5B5FDE);          // Main brand color
  static const Color primaryLight = Color(0xFFE8EAFD);     // Light variant
  static const Color primaryDark = Color(0xFF3D40A0);      // Dark variant

  // ACCENT COLOR
  // Warm gold for positive interactions (saves, completions)
  static const Color accent = Color(0xFFF4A460);

  // NEUTRAL COLORS
  // A clean gray scale for text, backgrounds, dividers
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0F0F0F);
  
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // SEMANTIC COLORS
  // Used for feedback and status
  static const Color success = Color(0xFF10B981);          
  static const Color warning = Color(0xFFF59E0B);          
  static const Color error = Color(0xFFEF4444);            
  static const Color info = Color(0xFF3B82F6);             

  // GRADIENTS
  // Used for backgrounds and premium feels
  static const LinearGradient meditationGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5B5FDE), 
      Color(0xFF8B5CF6),
    ],
  );

  static const LinearGradient calmGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFC7D2FE), 
      Color(0xFFDDD6FE), 
    ],
  );
}