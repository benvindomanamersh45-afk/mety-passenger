import 'package:flutter/material.dart';

class AppAnimations {
  // Durações padrão
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 300);

  // Curvas padrão
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.fastOutSlowIn;

  // Animação de fade in
  static Animation<double> fadeIn(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
  }

  // Animação de slide up
  static Animation<double> slideUp(AnimationController controller) {
    return Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
  }

  // Animação de scale
  static Animation<double> scale(AnimationController controller) {
    return Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
  }

  // Animação de shimmer
  static Animation<Color?> shimmer(AnimationController controller) {
    return ColorTween(
      begin: Colors.white.withOpacity(0.1),
      end: Colors.white.withOpacity(0.3),
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  // Widget animado genérico
  static Widget buildAnimatedWidget({
    required AnimationController controller,
    required Widget child,
    bool fade = true,
    bool slide = false,
    bool scale = false,
    double slideOffset = 30.0,
  }) {
    final animations = <Animation<double>>[];
    final builders = <Widget Function(Widget)>[];

    if (fade) {
      animations.add(fadeIn(controller));
      builders.add(
          (child) => FadeTransition(opacity: animations.last, child: child));
    }

    if (slide) {
      final slideAnim = Tween<double>(begin: slideOffset, end: 0.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
        ),
      );
      animations.add(slideAnim);
      builders.add((child) => SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, slideOffset / 100),
              end: Offset.zero,
            ).animate(slideAnim),
            child: child,
          ));
    }

    if (scale) {
      animations.add(scale as Animation<double>);
      builders.add(
          (child) => ScaleTransition(scale: animations.last, child: child));
    }

    Widget animatedChild = child;
    for (final builder in builders) {
      animatedChild = builder(animatedChild);
    }

    return animatedChild;
  }

  // Loading shimmer
  static Widget shimmerLoading(
      {double width = double.infinity, double height = 20}) {
    return ShimmerLoading(width: width, height: height);
  }

  // Pulsar animação
  static Animation<double> pulse(AnimationController controller) {
    return TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }
}

// Widget de shimmer loading
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _colorAnimation = AppAnimations.shimmer(_controller);
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
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                _colorAnimation.value!,
                _colorAnimation.value!.withOpacity(0.5),
                _colorAnimation.value!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// Widget de skeleton para carregamento
class SkeletonLoader extends StatelessWidget {
  final int itemCount;
  final Widget Function(int) itemBuilder;

  const SkeletonLoader({
    super.key,
    this.itemCount = 3,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return itemBuilder(index);
      },
    );
  }
}

// Exemplo de skeleton para viagem
Widget tripSkeletonLoader() {
  return SkeletonLoader(
    itemCount: 3,
    itemBuilder: (index) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerLoading(width: 100, height: 20),
            const SizedBox(height: 16),
            Row(
              children: [
                ShimmerLoading(
                    width: 24,
                    height: 24,
                    borderRadius: BorderRadius.circular(12)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoading(width: double.infinity, height: 16),
                      const SizedBox(height: 8),
                      ShimmerLoading(width: 150, height: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerLoading(width: 80, height: 20),
                ShimmerLoading(width: 60, height: 20),
              ],
            ),
          ],
        ),
      );
    },
  );
}
