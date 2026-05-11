// TODO Implement this library.
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  // Gradiente principal da METY
  static const Gradient mety = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.metyBlue, AppColors.metyBlueLight],
  );

  // Gradiente premium (para elementos especiais)
  static const Gradient premium = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.metyBlue, AppColors.metyGreen],
    stops: [0.0, 1.0],
  );

  // Gradiente energético (para botões de ação)
  static const Gradient energy = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.metyOrange, AppColors.metyYellow],
  );

  // Gradiente para cards
  static final Gradient card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.white.withOpacity(0.1),
      AppColors.white.withOpacity(0.05),
    ],
  );

  // Gradiente para background
  static final Gradient background = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.5,
    colors: [
      AppColors.metyBlue.withOpacity(0.1),
      AppColors.black,
    ],
    stops: const [0.0, 0.8],
  );

  // Gradiente para botões
  static const Gradient button = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.metyBlue, AppColors.metyBlueDark],
  );

  // Gradiente para sucesso
  static const Gradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.metyGreen, Color(0xFF00AA55)],
  );

  // Gradiente para alertas
  static const Gradient warning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.metyYellow, Color(0xFFFFAA00)],
  );

  // Gradiente para erros
  static const Gradient error = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF3333), Color(0xFFCC0000)],
  );

  // Gradiente para municípios
  static Gradient saurimo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.saurimo, AppColors.saurimo.withOpacity(0.7)],
  );

  static Gradient cassengo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.cassengo, AppColors.cassengo.withOpacity(0.7)],
  );

  static Gradient muangueji = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.muangueji, AppColors.muangueji.withOpacity(0.7)],
  );
}
