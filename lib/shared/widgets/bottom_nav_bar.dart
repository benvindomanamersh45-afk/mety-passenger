import 'package:flutter/material.dart';
import 'package:metty_pro/core/constants/theme/app_colors.dart';
import 'package:metty_pro/core/constants/theme/app_gradients.dart';
//import 'package:metty_pro/core/theme/app_colors.dart' hide AppColors;
//import 'package:metty_pro/core/theme/app_gradients.dart' hide AppGradients;

class PremiumBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;

  const PremiumBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<PremiumBottomNavBar> createState() => _PremiumBottomNavBarState();
}

class BottomNavItem {
  final IconData icon;
  final String label;
  final String route;

  const BottomNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class _PremiumBottomNavBarState extends State<PremiumBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.darkGray.withOpacity(0.95),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: const ColorFilter.mode(
            Colors.black54,
            BlendMode.darken,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              widget.items.length,
              (index) {
                final item = widget.items[index];
                final isSelected = widget.currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppGradients.premium : null,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Ícone com animação
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: isSelected ? 40 : 32,
                            height: isSelected ? 40 : 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Colors.transparent
                                  : AppColors.white.withOpacity(0.05),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : AppColors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              item.icon,
                              color: isSelected
                                  ? AppColors.black
                                  : AppColors.white.withOpacity(0.6),
                              size: isSelected ? 22 : 20,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Label
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: isSelected ? 10 : 9,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? AppColors.black
                                  : AppColors.white.withOpacity(0.6),
                              letterSpacing: isSelected ? 0.5 : 0,
                            ),
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// BottomNavBar para Home Screen com itens específicos
class HomeBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const HomeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumBottomNavBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavItem(
          icon: Icons.home_rounded,
          label: 'INÍCIO',
          route: '/home',
        ),
        BottomNavItem(
          icon: Icons.directions_car_rounded,
          label: 'VIAGENS',
          route: '/ride-request',
        ),
        BottomNavItem(
          icon: Icons.history_rounded,
          label: 'HISTÓRICO',
          route: '/history',
        ),
        BottomNavItem(
          icon: Icons.person_rounded,
          label: 'PERFIL',
          route: '/profile',
        ),
      ],
    );
  }
}

// Floating Action Button premium para ação principal
class PremiumFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;

  const PremiumFAB({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.darkGray,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.white.withOpacity(0.1),
              ),
            ),
            child: Text(
              label!,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppGradients.premium,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.black,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
