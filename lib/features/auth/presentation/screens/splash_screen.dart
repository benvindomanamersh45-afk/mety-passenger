import 'dart:math';
import 'package:flutter/material.dart';
import 'package:metty_pro/core/constants/theme/app_colors.dart';
import 'package:metty_pro/core/constants/theme/app_gradients.dart';
import 'package:metty_pro/features/auth/passenger/presentation/widgets/premium_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<double> _stars;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _stars = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // Fundo estrelado
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _stars,
              builder: (context, child) {
                return CustomPaint(
                  painter: StarsPainter(scale: _stars.value),
                );
              },
            ),
          ),

          // Gradiente de fundo
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    AppColors.primaryRed.withOpacity(0.15),
                    AppColors.black,
                  ],
                  stops: const [0.0, 0.8],
                ),
              ),
            ),
          ),

          Center(
            child: ScaleTransition(
              scale: _scale,
              child: FadeTransition(
                opacity: _opacity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const PremiumLogo(size: 120, animated: true),

                    const SizedBox(height: 40),

                    // Texto animado em PORTUGUÊS
                    Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return AppGradients.premium.createShader(bounds);
                          },
                          child: const Text(
                            'METTY PRO',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              height: 0.9,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'EXPERIÊNCIA TÁXI PREMIUM',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryGold.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'LUNDA SUL • ANGOLA',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.white.withOpacity(0.6),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mobilidade Redefinida',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primaryRed,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // Loader
                    Column(
                      children: [
                        Text(
                          'A carregar experiência premium...',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.white.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: 200,
                          child: LinearProgressIndicator(
                            backgroundColor: AppColors.white.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryGold,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            minHeight: 3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Saurimo • Cassengo • Muangueji',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.white.withOpacity(0.4),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Rodapé corrigido
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'DESENVOLVIDO POR',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.white.withOpacity(0.4),
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.metyBlue!.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.metyBlue!.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.developer_board_rounded,
                        color: AppColors.metyBlue,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'MBSoft Benvindo Mersh',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.metyBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StarsPainter extends CustomPainter {
  final double scale;

  StarsPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = Random(42);
    final center = Offset(size.width / 2, size.height / 2);

    // Estrelas
    for (int i = 0; i < 80; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final distance = random.nextDouble() * 400 * scale;
      final x = center.dx + cos(angle) * distance;
      final y = center.dy + sin(angle) * distance;
      final radius = 1 + random.nextDouble() * 2;
      final opacity = 0.2 + random.nextDouble() * 0.5;

      paint.color = Colors.white.withOpacity(opacity * scale);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Efeitos de partículas
    if (scale > 0.5) {
      for (int i = 0; i < 30; i++) {
        final x = random.nextDouble() * size.width;
        final y = random.nextDouble() * size.height;
        final radius = 0.5 + random.nextDouble() * 1.5;

        paint.color = AppColors.primaryRed.withOpacity(
          (scale - 0.5) * 2 * (0.1 + random.nextDouble() * 0.2),
        );
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StarsPainter oldDelegate) =>
      scale != oldDelegate.scale;
}