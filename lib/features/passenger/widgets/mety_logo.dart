import 'package:flutter/material.dart';
import 'package:metty_pro/core/theme/app_colors.dart';
import 'package:metty_pro/core/theme/app_gradients.dart';

class MetyLogo extends StatelessWidget {
  final double size;
  final bool withSlogan;
  final bool animated;
  final Color? color;
  final TextStyle? textStyle;
  final TextStyle? sloganStyle;

  const MetyLogo({
    super.key,
    this.size = 100,
    this.withSlogan = false,
    this.animated = false,
    this.color,
    this.textStyle,
    this.sloganStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logotipo METY
        if (animated) _buildAnimatedLogo() else _buildStaticLogo(),

        // Slogan
        if (withSlogan) ...[
          const SizedBox(height: 8),
          Text(
            'Confiança em cada corrida',
            style: sloganStyle ??
                TextStyle(
                  fontSize: size * 0.12,
                  color: color ?? AppColors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildStaticLogo() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return AppGradients.mety.createShader(bounds);
      },
      child: Text(
        'METY',
        style: textStyle ??
            TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w900,
              letterSpacing: 5,
              height: 0.9,
            ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Opacity(
            opacity: value,
            child: _buildStaticLogo(),
          ),
        );
      },
    );
  }
}

// Logotipo com ícone (para AppBar, etc.)
class MetyLogoIcon extends StatelessWidget {
  final double size;
  final bool withText;

  const MetyLogoIcon({
    super.key,
    this.size = 40,
    this.withText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ícone do logotipo
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppGradients.mety,
            borderRadius: BorderRadius.circular(size * 0.2),
          ),
          child: Center(
            child: Text(
              'M',
              style: TextStyle(
                fontSize: size * 0.6,
                fontWeight: FontWeight.w900,
                color: AppColors.white,
              ),
            ),
          ),
        ),

        // Texto opcional
        if (withText) ...[
          const SizedBox(width: 8),
          Text(
            'METY',
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              letterSpacing: 2,
            ),
          ),
        ],
      ],
    );
  }
}

// Logotipo para Splash Screen
class MetySplashLogo extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const MetySplashLogo({
    super.key,
    this.onAnimationComplete,
  });

  @override
  State<MetySplashLogo> createState() => _MetySplashLogoState();
}

class _MetySplashLogoState extends State<MetySplashLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      widget.onAnimationComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logotipo principal
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return AppGradients.premium.createShader(bounds);
                      },
                      child: Text(
                        'METY',
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 10,
                          height: 0.9,
                        ),
                      ),
                    ),

                    // Slogan
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'Confiança em cada corrida',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
