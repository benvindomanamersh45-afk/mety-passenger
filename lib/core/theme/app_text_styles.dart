// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:metty_pro/core/constants/theme/app_colors.dart';
//import 'package:metty_pro/core/theme/app_colors.dart' hide AppColors;

class AppTextStyles {
  // Famílias de fontes
  static const String inter = 'Inter';
  static const String poppins = 'Poppins';

  // Estilos de texto com Inter
  static TextStyle interHeading1 = const TextStyle(
    fontFamily: inter,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: -0.5,
  );

  static TextStyle interHeading2 = const TextStyle(
    fontFamily: inter,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: -0.3,
  );

  static TextStyle interHeading3 = const TextStyle(
    fontFamily: inter,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static TextStyle interTitle = const TextStyle(
    fontFamily: inter,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle interBody = const TextStyle(
    fontFamily: inter,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
    height: 1.5,
  );

  static TextStyle interBodyBold = const TextStyle(
    fontFamily: inter,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle interCaption = const TextStyle(
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );

  static TextStyle interSmall = const TextStyle(
    fontFamily: inter,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );

  // Estilos de texto com Poppins (para títulos premium)
  static TextStyle poppinsDisplay = const TextStyle(
    fontFamily: poppins,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: -1,
  );

  static TextStyle poppinsDisplaySmall = const TextStyle(
    fontFamily: poppins,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: -0.5,
  );

  static TextStyle poppinsButton = const TextStyle(
    fontFamily: poppins,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 0.5,
  );

  static TextStyle poppinsLabel = const TextStyle(
    fontFamily: poppins,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 1,
  );

  // Estilos específicos para componentes
  static TextStyle appBarTitle = const TextStyle(
    fontFamily: inter,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: 1,
  );

  static TextStyle buttonText = const TextStyle(
    fontFamily: poppins,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 1,
  );

  static TextStyle inputLabel = const TextStyle(
    fontFamily: inter,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 1,
  );

  static TextStyle priceText = const TextStyle(
    fontFamily: poppins,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryGold,
  );

  static TextStyle vehicleName = const TextStyle(
    fontFamily: poppins,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
  );

  // Métodos para opacidade
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withOpacity(opacity));
  }

  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withGradient(TextStyle style, Gradient gradient) {
    return style.copyWith(
        foreground: Paint()
          ..shader = gradient.createShader(
            const Rect.fromLTWH(0, 0, 200, 50),
          ));
  }
}
