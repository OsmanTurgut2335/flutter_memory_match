import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mem_game/core/constants/colors/app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();
  static final leaderboardHeader = GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.lightTextPrimary,
  );

  static final leaderboardScore = GoogleFonts.roboto(fontSize: 14, color: AppColors.lightTextPrimary);

  static final whiteBold18 = GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.lightTextPrimary,
  );
}
