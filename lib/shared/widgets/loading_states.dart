import 'package:flutter/material.dart';
import 'package:metty_pro/core/constants/theme/app_colors.dart';
import 'package:metty_pro/core/constants/theme/app_gradients.dart';
//import 'package:metty_pro/core/theme/app_colors.dart' hide AppColors;
//import 'package:metty_pro/core/theme/app_gradients.dart' hide AppGradients;
import 'package:metty_pro/features/auth/passenger/presentation/widgets/glass_card.dart';
import 'package:metty_pro/features/passenger/widgets/gradient_button.dart';

// Estado de carregamento padrão
class LoadingState extends StatelessWidget {
  final String message;
  final bool showBackground;

  const LoadingState({
    super.key,
    this.message = 'Carregando...',
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLoadingSpinner(),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSpinner() {
    return Container(
      width: 60,
      height: 60,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppGradients.premium,
        shape: BoxShape.circle,
      ),
      child: CircularProgressIndicator(
        color: AppColors.black,
        strokeWidth: 3,
      ),
    );
  }
}

// Estado vazio (sem dados)
class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    this.title = 'Nenhum dado encontrado',
    this.description = 'Não há informações para mostrar no momento',
    this.icon = Icons.inbox_rounded,
    this.iconColor = AppColors.primaryGold,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null) ...[
              const SizedBox(height: 24),
              GradientButton(
                text: buttonText!,
                onPressed: onButtonPressed,
                gradient: AppGradients.premium,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                fullWidth: false,
                type: null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Estado de erro
class ErrorState extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onRetry;

  const ErrorState({
    super.key,
    this.title = 'Algo deu errado',
    this.description = 'Não foi possível carregar os dados',
    this.buttonText = 'TENTAR NOVAMENTE',
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: buttonText,
              onPressed: onRetry,
              gradient: LinearGradient(
                colors: [
                  AppColors.error.withOpacity(0.8),
                  AppColors.error,
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              fullWidth: false,
              type: null,
            ),
          ],
        ),
      ),
    );
  }
}

// Estado de conexão perdida
class NoConnectionState extends StatelessWidget {
  final VoidCallback onRetry;

  const NoConnectionState({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Sem conexão',
      description: 'Verifique sua conexão com a internet e tente novamente',
      icon: Icons.wifi_off_rounded,
      iconColor: AppColors.error,
      buttonText: 'TENTAR NOVAMENTE',
      onButtonPressed: onRetry,
    );
  }
}

// Estado de busca sem resultados
class NoResultsState extends StatelessWidget {
  final String searchTerm;

  const NoResultsState({
    super.key,
    required this.searchTerm,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Nenhum resultado',
      description: 'Não encontramos resultados para "$searchTerm"',
      icon: Icons.search_off_rounded,
      iconColor: AppColors.info,
    );
  }
}

// Estado de sucesso
class SuccessState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String buttonText;
  final VoidCallback onContinue;

  const SuccessState({
    super.key,
    this.title = 'Sucesso!',
    this.description = 'Operação concluída com sucesso',
    this.icon = Icons.check_circle_rounded,
    this.buttonText = 'CONTINUAR',
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppGradients.premium,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.black,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: buttonText,
              onPressed: onContinue,
              gradient: AppGradients.premium,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              fullWidth: false,
              type: null,
            ),
          ],
        ),
      ),
    );
  }
}

// Skeleton loader para lista de viagens
class TripListSkeleton extends StatelessWidget {
  final int itemCount;

  const TripListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              // Header skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Route skeleton
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: AppColors.white.withOpacity(0.1),
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Footer skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 80,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// Loading overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message = 'Processando...',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColors.black.withOpacity(0.7),
            child: Center(
              child: GlassCard(
                padding: const EdgeInsets.all(32),
                borderRadius: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppGradients.premium,
                        shape: BoxShape.circle,
                      ),
                      child: const CircularProgressIndicator(
                        color: AppColors.black,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
