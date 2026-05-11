import 'package:flutter/material.dart';
import 'package:metty_pro/core/constants/theme/app_colors.dart';
//import 'package:metty_pro/core/theme/app_colors.dart' hide AppColors;

class AppIcons {
  // Ícones de veículos
  static Widget premiumCar({double size = 32, Color? color}) {
    return Icon(
      Icons.directions_car_filled_rounded,
      color: color ?? AppColors.primaryGold,
      size: size,
    );
  }

  static Widget comfortCar({double size = 32, Color? color}) {
    return Icon(
      Icons.directions_car_rounded,
      color: color ?? AppColors.primaryRed,
      size: size,
    );
  }

  static Widget economyCar({double size = 32, Color? color}) {
    return Icon(
      Icons.electric_car_rounded,
      color: color ?? AppColors.success,
      size: size,
    );
  }

  // Ícones de pagamento
  static Widget money({double size = 24, Color? color}) {
    return Icon(
      Icons.money_rounded,
      color: color ?? AppColors.success,
      size: size,
    );
  }

  static Widget creditCard({double size = 24, Color? color}) {
    return Icon(
      Icons.credit_card_rounded,
      color: color ?? AppColors.primaryRed,
      size: size,
    );
  }

  static Widget mpesa({double size = 24, Color? color}) {
    return Icon(
      Icons.phone_android_rounded,
      color: color ?? AppColors.info,
      size: size,
    );
  }

  // Ícones de municípios
  static Widget saurimo({double size = 32, Color? color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.saurimo,
            AppColors.saurimo.withOpacity(0.7),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.location_city_rounded,
        color: AppColors.white,
        size: size * 0.6,
      ),
    );
  }

  static Widget cassengo({double size = 32, Color? color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cassengo,
            AppColors.cassengo.withOpacity(0.7),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.store_rounded,
        color: AppColors.white,
        size: size * 0.6,
      ),
    );
  }

  static Widget muangueji({double size = 32, Color? color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.muangueji,
            AppColors.muangueji.withOpacity(0.7),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.school_rounded,
        color: AppColors.white,
        size: size * 0.6,
      ),
    );
  }

  // Ícones de status
  static Widget success({double size = 24}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.success),
      ),
      child: Icon(
        Icons.check_rounded,
        color: AppColors.success,
        size: size * 0.6,
      ),
    );
  }

  static Widget error({double size = 24}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.error),
      ),
      child: Icon(
        Icons.close_rounded,
        color: AppColors.error,
        size: size * 0.6,
      ),
    );
  }

  static Widget warning({double size = 24}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.warning),
      ),
      child: Icon(
        Icons.warning_rounded,
        color: AppColors.warning,
        size: size * 0.6,
      ),
    );
  }

  // Ícones de navegação
  static Widget home({double size = 24, bool active = false}) {
    return Icon(
      Icons.home_rounded,
      color: active ? AppColors.primaryGold : AppColors.white.withOpacity(0.6),
      size: size,
    );
  }

  static Widget ride({double size = 24, bool active = false}) {
    return Icon(
      Icons.directions_car_rounded,
      color: active ? AppColors.primaryRed : AppColors.white.withOpacity(0.6),
      size: size,
    );
  }

  static Widget history({double size = 24, bool active = false}) {
    return Icon(
      Icons.history_rounded,
      color: active ? AppColors.info : AppColors.white.withOpacity(0.6),
      size: size,
    );
  }

  static Widget profile({double size = 24, bool active = false}) {
    return Icon(
      Icons.person_rounded,
      color: active ? AppColors.success : AppColors.white.withOpacity(0.6),
      size: size,
    );
  }
}
