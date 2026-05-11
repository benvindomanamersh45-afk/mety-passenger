// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:metty_pro/core/theme/app_colors.dart';

class CityChip extends StatelessWidget {
  final String city;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isSmallScreen;
  final bool isVerySmallScreen;

  const CityChip({
    super.key,
    required this.city,
    required this.isSelected,
    required this.onTap,
    required this.isSmallScreen,
    required this.isVerySmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18),
          vertical: isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12),
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.metyBlue, AppColors.metyGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppColors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? AppColors.metyBlue.withOpacity(0.5)
                : AppColors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Text(
          city,
          style: TextStyle(
            fontSize: isVerySmallScreen ? 13 : (isSmallScreen ? 14 : 15),
            fontWeight: FontWeight.w600,
            color:
                isSelected ? AppColors.white : AppColors.white.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}
