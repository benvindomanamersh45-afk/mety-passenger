// TODO Implement this library.
import 'package:flutter/material.dart';

class AppColors {
  // Cores da marca METY
  static const Color metyBlue = Color(0xFF0066CC); // Azul principal da METY
  static const Color metyBlueLight = Color(0xFF3399FF);
  static const Color metyBlueDark = Color(0xFF004C99);
  static const Color metyGreen =
      Color(0xFF00CC66); // Verde para sucesso/ecológico
  static const Color metyOrange =
      Color(0xFFFF6600); // Laranja para ação/energia
  static const Color metyYellow = Color(0xFFFFCC00); // Amarelo para atenção

  // Cores base do tema
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGrey = Color(0xFF1A1A1A);
  static const Color grey = Color(0xFF333333);
  static const Color lightGrey = Color(0xFF666666);

  // Cores funcionais
  static const Color success = metyGreen;
  static const Color error = Color(0xFFFF3333);
  static const Color warning = metyYellow;
  static const Color info = metyBlueLight;

  // Cores para municípios (mantendo mas ajustando tons)
  static const Color saurimo = Color(0xFF1E90FF); // Azul mais claro
  static const Color cassengo = Color(0xFFFF7F50); // Coral
  static const Color muangueji = Color(0xFF9B59B6); // Roxo

  // Gradientes
  static Gradient get metyGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [metyBlue, metyBlueLight],
      );

  static Gradient get premiumGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [metyBlue, metyGreen],
      );

  static Gradient get energyGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [metyOrange, metyYellow],
      );

  // Cores para tipos de veículo
  static const Color premium = metyBlue;
  static const Color comfort = metyOrange;
  static const Color economy = metyGreen;

  static Color? get metyPurple => null;

  // Métodos auxiliares
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
