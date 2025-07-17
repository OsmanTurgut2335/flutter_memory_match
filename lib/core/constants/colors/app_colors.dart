// lib/core/constants/colors/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF3F51B5); // Indigo shade.
  static const Color accent = Color(0xFFFF5722); // Deep orange.
  static const Color scaffoldBackground = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color cardBorder = Color(0xFFE0E0E0); // Light grey.
  static const Color shadowColor = Colors.black26;
  static const Color shimmerBase = Colors.blue;
  static const Color shimmerHighlight = Colors.lightBlueAccent;

  // General text colors
  static const Color textPrimary = Color(0xFF212121); // Dark grey.
  static const Color textSecondary = Color(0xFF757575); // Grey.

  // NEW: For light text on colored backgrounds like gradients
  static const Color lightTextPrimary = Colors.white;
  static const Color lightTextSecondary = Colors.white70;
}
