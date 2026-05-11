import 'package:flutter/material.dart';
//import '../../core/theme/app_colors.dart';

class CityChip extends StatelessWidget {
  final String city;
  final Color color;
  final IconData icon;
  final bool glowing;

  const CityChip({
    super.key,
    required this.city,
    required this.color,
    required this.icon,
    this.glowing = true,
    required bool isActive,
    required bool isSmall,
    required bool isSelected,
    required Null Function() onTap,
    required bool isSmallScreen,
    required bool isVerySmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: glowing
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            city,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
