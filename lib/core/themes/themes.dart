// lib/core/themes/themes.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mem_game/core/constants/colors/app_colors.dart';
import 'package:mem_game/core/constants/paddings/app_dimensions.dart';
import 'package:mem_game/core/constants/paddings/app_paddings.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.scaffoldBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 4,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    textTheme: GoogleFonts.robotoTextTheme(ThemeData.light().textTheme).copyWith(
      bodyLarge: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      bodyMedium: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
      headlineSmall: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFA726),
        foregroundColor: Colors.black87,
        padding: AppPaddings.buttonPadding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.buttonCornerRadius)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(actionTextColor: Colors.black, backgroundColor: Colors.white),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      contentTextStyle: const TextStyle(fontSize: 16, color: Colors.black87),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.primary.withOpacity(0.1),
      textStyle: const TextStyle(color: AppColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
    ),

    cardTheme: CardThemeData(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.buttonCornerRadius)),
      margin: AppPaddings.all8,
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      // Other color properties can go here.
    ),
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 4,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme).copyWith(
      bodyLarge: const TextStyle(fontSize: 16, color: Colors.white70),
      bodyMedium: const TextStyle(fontSize: 14, color: Colors.white70),
      headlineSmall: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: AppPaddings.all8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.buttonCornerRadius)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      // For dark theme, for example:
      color: AppColors.primary.withOpacity(0.7),
      textStyle: const TextStyle(color: Colors.white70),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.cardCornerRadius)),
      margin: AppPaddings.all8,
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      // Other color properties can go here.
    ),
  );
}
