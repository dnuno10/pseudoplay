import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static final title = GoogleFonts.ibmPlexMono(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static final subtitle = GoogleFonts.ibmPlexMono(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static final body = GoogleFonts.ibmPlexMono(
    fontSize: 16,
    color: AppColors.textDark,
  );

  static final small = GoogleFonts.ibmPlexMono(
    fontSize: 14,
    color: AppColors.textDark,
  );

  static final code = GoogleFonts.ibmPlexMono(
    fontSize: 16,
    color: AppColors.textDark,
  );

  static final console = GoogleFonts.ibmPlexMono(
    fontSize: 16,
    color: AppColors.textLight,
  );
}
