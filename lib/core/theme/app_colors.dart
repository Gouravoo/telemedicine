import 'package:flutter/material.dart';

/// AarogyaPlus Color System
/// Trust-first medical aesthetic — calm teal-green palette
class AppColors {
  AppColors._();

  // ─── Brand Primary (Teal-Green — Medical Trust) ───
  static const Color primary = Color(0xFF0F9D8C);
  static const Color primaryDark = Color(0xFF0B6E62);
  static const Color primaryLight = Color(0xFF4ECDC4);
  static const Color primarySurface = Color(0xFFE8F8F5);

  // ─── Secondary / Accent (Soft Indigo — Doctor Role) ───
  static const Color secondary = Color(0xFF3D5AFE);
  static const Color secondaryDark = Color(0xFF2A3EB1);
  static const Color secondaryLight = Color(0xFF8C9EFF);
  static const Color secondarySurface = Color(0xFFEEF0FF);

  // ─── Semantic Colors ───
  static const Color success = Color(0xFF2ECC71);
  static const Color successSurface = Color(0xFFEAFAF1);
  static const Color warning = Color(0xFFF5A623);
  static const Color warningSurface = Color(0xFFFEF5E7);
  static const Color error = Color(0xFFE63946);
  static const Color errorSurface = Color(0xFFFDECEE);
  static const Color info = Color(0xFF3498DB);
  static const Color infoSurface = Color(0xFFEBF5FB);

  // ─── Backgrounds ───
  static const Color background = Color(0xFFF7FAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F4);
  static const Color scaffoldBackground = Color(0xFFF7FAFA);

  // ─── Text ───
  static const Color textPrimary = Color(0xFF1A2E2B);
  static const Color textSecondary = Color(0xFF6B7A78);
  static const Color textTertiary = Color(0xFF9BABA8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFE8F0EF);

  // ─── Borders & Dividers ───
  static const Color border = Color(0xFFE2E8E7);
  static const Color borderLight = Color(0xFFF0F4F4);
  static const Color divider = Color(0xFFE8EDED);

  // ─── Video Call (Dark Theme) ───
  static const Color callBackground = Color(0xFF0D1B1A);
  static const Color callSurface = Color(0xFF1A2E2B);
  static const Color callControlBg = Color(0xFF2A3E3B);
  static const Color callEndButton = Color(0xFFE63946);

  // ─── Shadows ───
  static const Color shadowLight = Color(0x0F000000); // 6% opacity
  static const Color shadowMedium = Color(0x1A000000); // 10% opacity

  // ─── Role-based accent maps ───
  static const Color patientAccent = primary;
  static const Color doctorAccent = secondary;
  static const Color adminAccent = Color(0xFF546E7A); // Slate

  // ─── Status Colors (for appointment chips) ───
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return warning;
      case 'accepted':
        return info;
      case 'completed':
        return success;
      case 'rejected':
      case 'cancelled':
        return error;
      default:
        return textSecondary;
    }
  }

  static Color statusSurface(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return warningSurface;
      case 'accepted':
        return infoSurface;
      case 'completed':
        return successSurface;
      case 'rejected':
      case 'cancelled':
        return errorSurface;
      default:
        return surfaceVariant;
    }
  }
}
