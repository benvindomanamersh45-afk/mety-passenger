import 'package:flutter/material.dart';
import 'package:metty_pro/core/constants/theme/app_colors.dart';
//import 'package:metty_pro/core/theme/app_colors.dart' hide AppColors;

class AppBackgrounds {
  // Gradientes de fundo para cada município
  static BoxDecoration saurimoBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.saurimo.withOpacity(0.3),
        AppColors.black,
      ],
      stops: const [0.0, 0.8],
    ),
  );

  static BoxDecoration cassengoBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.cassengo.withOpacity(0.3),
        AppColors.black,
      ],
      stops: const [0.0, 0.8],
    ),
  );

  static BoxDecoration muanguejiBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.muangueji.withOpacity(0.3),
        AppColors.black,
      ],
      stops: const [0.0, 0.8],
    ),
  );

  // Background genérico premium
  static BoxDecoration premiumBackground = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment.topCenter,
      radius: 1.5,
      colors: [
        AppColors.primaryGold.withOpacity(0.2),
        AppColors.primaryRed.withOpacity(0.1),
        AppColors.black,
      ],
      stops: const [0.0, 0.4, 1.0],
    ),
  );

  // Background para telas de autenticação
  static BoxDecoration authBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.darkGray,
        AppColors.black,
      ],
    ),
  );

  // Widget de background com gradiente animado
  static Widget animatedBackground({Widget? child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryRed.withOpacity(0.1),
            AppColors.primaryGold.withOpacity(0.05),
            AppColors.black,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: child,
    );
  }

  // Widget de background com partículas
  static Widget particlesBackground({Widget? child}) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.black,
                AppColors.darkGray,
              ],
            ),
          ),
        ),
        // Simulação de partículas
        Positioned.fill(
          child: CustomPaint(
            painter: _ParticlesPainter(),
          ),
        ),
        if (child != null) child,
      ],
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGold.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Desenhar partículas aleatórias
    for (int i = 0; i < 50; i++) {
      final x = (i * 73) % size.width.toDouble();
      final y = (i * 37) % size.height.toDouble();
      final radius = 1 + (i % 3).toDouble();

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
