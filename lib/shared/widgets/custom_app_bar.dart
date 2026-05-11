import 'package:flutter/material.dart';
import 'package:metty_pro/core/theme/app_colors.dart';
import 'package:metty_pro/core/theme/app_gradients.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showProfileButton;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfilePressed;
  final Color? backgroundColor;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.showProfileButton = true,
    this.actions,
    this.onBackPressed,
    this.onProfilePressed,
    this.backgroundColor,
    this.centerTitle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isVerySmallScreen = screenWidth < 360;

    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      centerTitle: centerTitle,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.black.withOpacity(0.9),
              AppColors.black.withOpacity(0.7),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
      leading: showBackButton
          ? Padding(
              padding: EdgeInsets.only(
                left: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20),
              ),
              child: GestureDetector(
                onTap: onBackPressed ?? () => Navigator.pop(context),
                child: Container(
                  width: isVerySmallScreen ? 36 : 40,
                  height: isVerySmallScreen ? 36 : 40,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.white,
                    size: isVerySmallScreen ? 18 : 20,
                  ),
                ),
              ),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontSize: isVerySmallScreen ? 18 : (isSmallScreen ? 20 : 22),
          fontWeight: FontWeight.w800,
          color: AppColors.white,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        if (showProfileButton)
          Padding(
            padding: EdgeInsets.only(
              right: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20),
            ),
            child: GestureDetector(
              onTap: onProfilePressed ??
                  () {
                    Navigator.pushNamed(context, '/profile');
                  },
              child: Container(
                width: isVerySmallScreen ? 36 : 40,
                height: isVerySmallScreen ? 36 : 40,
                decoration: BoxDecoration(
                  gradient: AppGradients.mety,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.white,
                  size: isVerySmallScreen ? 18 : 20,
                ),
              ),
            ),
          ),
        ...?actions,
      ],
    );
  }
}

// AppBar para telas sem título (apenas botões)
class MinimalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final bool showProfileButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfilePressed;
  final Color? backgroundColor;
  final List<Widget>? actions;

  const MinimalAppBar({
    super.key,
    this.showBackButton = true,
    this.showProfileButton = true,
    this.onBackPressed,
    this.onProfilePressed,
    this.backgroundColor,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isVerySmallScreen = screenWidth < 360;

    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: 70,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.black.withOpacity(0.9),
              AppColors.black.withOpacity(0.7),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
      leading: showBackButton
          ? Padding(
              padding: EdgeInsets.only(
                left: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20),
              ),
              child: GestureDetector(
                onTap: onBackPressed ?? () => Navigator.pop(context),
                child: Container(
                  width: isVerySmallScreen ? 36 : 40,
                  height: isVerySmallScreen ? 36 : 40,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.white,
                    size: isVerySmallScreen ? 18 : 20,
                  ),
                ),
              ),
            )
          : null,
      actions: [
        if (showProfileButton)
          Padding(
            padding: EdgeInsets.only(
              right: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20),
            ),
            child: GestureDetector(
              onTap: onProfilePressed ??
                  () {
                    Navigator.pushNamed(context, '/profile');
                  },
              child: Container(
                width: isVerySmallScreen ? 36 : 40,
                height: isVerySmallScreen ? 36 : 40,
                decoration: BoxDecoration(
                  gradient: AppGradients.mety,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.white,
                  size: isVerySmallScreen ? 18 : 20,
                ),
              ),
            ),
          ),
        ...?actions,
      ],
    );
  }
}
