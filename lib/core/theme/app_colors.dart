import 'package:flutter/material.dart';

/// Central colour palette extracted verbatim from the "Pitch TZ – All Screens"
/// design. Keep every literal hex in one place so screens stay consistent.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF0E3B2C); // deep pitch green
  static const Color primaryDark = Color(0xFF0E2A1F); // lime-on text green
  static const Color primaryGradientEnd = Color(0xFF155440);
  static const Color lime = Color(0xFFC9F24E); // accent
  static const Color linkHover = Color(0xFF3E7C5B);

  // Surfaces
  static const Color cream = Color(0xFFF5F4EF); // app background
  static const Color backdrop = Color(0xFF101512); // outside the device frame
  static const Color white = Color(0xFFFFFFFF);
  static const Color scanPayBg = Color(0xFFEDECE5);

  // Text
  static const Color ink = Color(0xFF171B18); // primary text
  static const Color bodyText = Color(0xFF454B46); // review body
  static const Color muted = Color(0xFF6E756F);
  static const Color faint = Color(0xFF9AA09A); // placeholders

  // Borders & dividers
  static const Color border = Color(0xFFE7E5DD);
  static const Color borderLight = Color(0xFFECEAE2);
  static const Color divider = Color(0xFFF1EFE8);
  static const Color inputBorder = Color(0xFFE1DFD5);
  static const Color neutralFill = Color(0xFFE9E7DF); // segmented control bg
  static const Color handle = Color(0xFFD4D2C8);

  // Success / info
  static const Color successText = Color(0xFF2E7D46);
  static const Color successBg = Color(0xFFEAF2E4);
  static const Color navActiveBg = Color(0xFFDCEFC8);
  static const Color danger = Color(0xFFB44940); // heart / cancel
  static const Color star = Color(0xFFDFA53C);

  // Map
  static const Color mapBg = Color(0xFFE8EAE2);
  static const Color mapWater = Color(0xFFCFE0EA);
  static const Color mapWaterLabel = Color(0xFF7791A0);
  static const Color mapUser = Color(0xFF3B82D4);

  // Accent labels used on cards
  static const Color orange = Color(0xFFB4682E);
  static const Color orangeBg = Color(0xFFF7ECDD);
  static const Color fantasyBlue = Color(0xFF3D5A96);
  static const Color fantasyBg = Color(0xFFE4EAF5);
  static const Color whatsapp = Color(0xFF22B14C);

  // Payment brand marks
  static const Color mpesa = Color(0xFF3FA34D);
  static const Color airtel = Color(0xFFD9403A);
  static const Color mixx = Color(0xFFE8A93B);
  static const Color halo = Color(0xFFC96A2E);
  static const Color card = Color(0xFF4A5A96);
}
