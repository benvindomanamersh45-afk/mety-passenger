import 'package:flutter/material.dart';

class AppGradients {
  // Gradientes principais
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFFC8102E), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premium = LinearGradient(
    colors: [Color(0xFFC8102E), Color(0xFFFF6B35), Color(0xFFFFD700)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gold = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFC400)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradientes por município
  static const LinearGradient saurimoGradient = LinearGradient(
    colors: [Color(0xFFC8102E), Color(0xFF8B0000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cassengoGradient = LinearGradient(
    colors: [Color(0xFF009E60), Color(0xFF006B3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient muanguejiGradient = LinearGradient(
    colors: [Color(0xFF003DA5), Color(0xFF002D62)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradientes de fundo
  static const RadialGradient background = RadialGradient(
    colors: [Color(0xFFC8102E), Colors.black],
    center: Alignment.topRight,
    radius: 1.5,
  );

  static Gradient? get driver => null;
}
