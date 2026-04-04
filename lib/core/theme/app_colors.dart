import 'package:flutter/material.dart';

import '../constants/app_constants.dart';


class AppColors {
 //Couleurs utilisé
  static const primaryNavy  = Color(0xFF1E293B);
  static const dashboardBg  = Color(0xFF0F172A);
  static const indigo       = Color(0xFF6366F1);
  static const indigoDark   = Color(0xFF4F46E5);
  static const successGreen = Color(0xFF10B981);
  static const successDark  = Color(0xFF059669);
  static const alertOrange  = Color(0xFFF97316);
  static const errorRed     = Color(0xFFEF4444);
  static const errorDark    = Color(0xFFDC2626);

  static const background   = Color(0xFFF8FAFC);
  static const white        = Color(0xFFFFFFFF);
  static const border       = Color(0xFFE2E8F0);
  static const muted        = Color(0xFFF1F5F9);
  static const foreground   = Color(0xFF0F172A);
  static const textMuted    = Color(0xFF64748B);


//couleurs des catégories
  static Map<String, Color> getCategoryTheme(String category) {
    switch (category) {
      case ProductCategory.alimentaire:
        return {'bg': Color(0xFFD1FAE5), 'text': Color(0xFF059669)};
      case ProductCategory.hygiene:
        return {'bg': Color(0xFFE0E7FF), 'text': Color(0xFF4F46E5)};
      case ProductCategory.energie:
        return {'bg': Color(0xFFFFEDD5), 'text': Color(0xFFD97706)};
      case ProductCategory.entretien:
        return {'bg': Color(0xFFF1F5F9), 'text': Color(0xFF475569)};
      case ProductCategory.sante:
        return {'bg': Color(0xFFFEE2E2), 'text': Color(0xFFDC2626)};
      default:
        return {'bg': Color(0xFFF1F5F9), 'text': Color(0xFF475569)};
    }
  }

  //couleurs pour les emplacements
  static Color getLocationColor(String location) {
    switch (location) {
      case ProductLocation.frigo:
      case ProductLocation.congelateur:
        return Color(0xFF0EA5E9);
      case ProductLocation.placard:
      case ProductLocation.gardeManger:
        return Color(0xFFF59E0B);

      case ProductLocation.salleDeBain:
        return const Color(0xFF6366F1);

        default:
        return Color(0xFF64748B);
    }
  }
}
