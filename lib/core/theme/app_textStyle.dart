import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  static TextStyle h1 = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );


  // Titre d'ecran
  static TextStyle h2 = GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.white,
  );

  static TextStyle h3 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.foreground,
  );


  // Nom du produit
  static TextStyle productTitle = GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.foreground,
  );

  // Chiffre de stock
  static TextStyle stockCount = GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.foreground,
  );

  // Détails
  static TextStyle stockSub  = GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textMuted,
  );

 //body: texte courant
  static TextStyle body = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.foreground,
  );

  //texte secondaire
  static TextStyle subtitle = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  //texte des badges
  static TextStyle badge = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  // Badge "Stock Faible" orange
  static TextStyle badgeAlert = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.alertOrange,
  );

 //label au dessus des champs pour les formulaires
  static TextStyle fieldLabel = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.foreground,
  );
 //texte dans les champs
  static TextStyle fieldValue = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.foreground,
  );

  //placeholder
  static TextStyle fieldHint = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );


  // boutons primaire
  static TextStyle button = GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.5
  );

  //navigation
  static TextStyle navLabel = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  //caption
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  //valeur : prix
  static TextStyle money = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.successGreen,
  );



}
