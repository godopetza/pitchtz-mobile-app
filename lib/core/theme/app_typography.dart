import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Plus Jakarta Sans text styles. The design leans heavily on weight 800 for
/// headings and 700 for emphasis, with tight negative letter-spacing on titles.
class AppText {
  AppText._();

  static TextStyle _base(double size, FontWeight weight,
          {Color color = AppColors.ink, double? spacing, double? height}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: spacing,
        height: height,
      );

  // Display / headings
  static TextStyle get splashTitle =>
      _base(30, FontWeight.w800, color: AppColors.cream, spacing: -0.5);
  static TextStyle get h1 => _base(30, FontWeight.w800, spacing: -0.6, height: 1.1);
  static TextStyle get h2 => _base(22, FontWeight.w800, spacing: -0.4);
  static TextStyle get h3 => _base(20, FontWeight.w800, spacing: -0.3);
  static TextStyle get sectionTitle => _base(19, FontWeight.w800, spacing: -0.3);
  static TextStyle get cardTitleLg => _base(17, FontWeight.w800, spacing: -0.2);
  static TextStyle get title => _base(16, FontWeight.w800);
  static TextStyle get cardTitle => _base(15, FontWeight.w800, spacing: -0.2);

  // Body
  static TextStyle get body => _base(14, FontWeight.w500, height: 1.5);
  static TextStyle get bodyMuted =>
      _base(13.5, FontWeight.w500, color: AppColors.muted, height: 1.5);
  static TextStyle get label => _base(13, FontWeight.w700);
  static TextStyle get small =>
      _base(12.5, FontWeight.w500, color: AppColors.muted);
  static TextStyle get tiny =>
      _base(11.5, FontWeight.w500, color: AppColors.muted);
  static TextStyle get overline => _base(11, FontWeight.w800,
      color: AppColors.faint, spacing: 0.8);

  // Buttons
  static TextStyle get button =>
      _base(16, FontWeight.w800, color: AppColors.cream);
  static TextStyle get mono => GoogleFonts.robotoMono(
      fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 3);
}
