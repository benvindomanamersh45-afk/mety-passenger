import 'package:flutter/material.dart';
import 'package:metty_pro/core/constants/theme/app_gradients.dart';
//import '../../core/theme/app_gradients.dart';

class PremiumLogo extends StatelessWidget {
  final double size;
  final bool withText;
  final bool animated;

  const PremiumLogo({
    super.key,
    this.size = 150,
    this.withText = true,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget logo = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppGradients.premium,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 50,
            spreadRadius: 20,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.08),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.directions_car_filled,
              size: size * 0.4,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    if (animated) {
      logo = RotationTransition(
        turns: const AlwaysStoppedAnimation(0),
        child: logo,
      );
    }

    if (!withText) {
      return logo;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) {
            return AppGradients.premium.createShader(bounds);
          },
          child: const Text(
            'METTY',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'by Katokampos',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
