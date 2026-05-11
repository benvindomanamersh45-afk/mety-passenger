import 'package:flutter/material.dart';
import 'package:metty_pro/core/constants/theme/app_gradients.dart';
//import '../../core/theme/app_gradients.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool fullWidth;
  final double height;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient = AppGradients.primary,
    this.icon,
    this.fullWidth = true,
    this.height = 60,
    required bool isLoading,
    required EdgeInsets padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: fullWidth ? double.infinity : null,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
