import 'package:flutter/material.dart';
import 'package:metty_pro/core/theme/app_colors.dart';
import 'package:metty_pro/core/theme/app_gradients.dart';
import 'package:metty_pro/features/auth/passenger/presentation/widgets/glass_card.dart';
//import 'package:metty_pro/features/passenger/widgets/glass_card.dart';
import 'package:metty_pro/features/passenger/widgets/gradient_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Logotipo METY
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return AppGradients.premium
                                    .createShader(bounds);
                              },
                              child: const Text(
                                'METY',
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 6,
                                  height: 0.9,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Confiança em cada corrida',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                // Card de boas-vindas
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value * 1.3),
                        child: GlassCard(
                          padding: const EdgeInsets.all(24),
                          borderRadius: 20,
                          child: Column(
                            children: [
                              // Ícone de boas-vindas
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: AppGradients.mety,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.emoji_transportation_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),

                              const SizedBox(height: 20),

                              Text(
                                'Bem-vindo ao METY',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.white,
                                  letterSpacing: 1,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                'O aplicativo premium de transporte da Lunda Sul. '
                                'Oferecemos viagens seguras, confortáveis e com a '
                                'confiança que você merece em cada corrida.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.white.withOpacity(0.7),
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Municípios atendidos
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: [
                                  _buildCityChip('Saurimo', AppColors.saurimo,
                                      Icons.location_city_rounded),
                                  _buildCityChip('Cassengo', AppColors.cassengo,
                                      Icons.store_rounded),
                                  _buildCityChip(
                                      'Muangueji',
                                      AppColors.muangueji,
                                      Icons.school_rounded),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                // Botões de ação
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value * 1.6),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: GradientButton(
                                text: 'INICIAR SESSÃO',
                                onPressed: () {
                                  Navigator.pushNamed(context, '/login');
                                },
                                gradient: AppGradients.mety,
                                icon: Icons.login_rounded,
                                fullWidth: false,
                                type: false,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: GradientButton(
                                text: 'CRIAR CONTA',
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                gradient: AppGradients.energy,
                                icon: Icons.person_add_rounded,
                                type: ButtonType.outlined,
                                fullWidth: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Créditos dos desenvolvedores
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value * 1.8),
                        child: Column(
                          children: [
                            Divider(
                              color: AppColors.white.withOpacity(0.1),
                              height: 20,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Desenvolvido por',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.white.withOpacity(0.4),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildDeveloperChip('KatoKampos'),
                                const SizedBox(width: 12),
                                _buildDeveloperChip('MBSoft'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '© 2024 METY Pro - Todos os direitos reservados',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.white.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCityChip(String city, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            city,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperChip(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.metyBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.code_rounded,
            color: AppColors.metyBlue.withOpacity(0.7),
            size: 12,
          ),
          const SizedBox(width: 5),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.metyBlue.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ButtonType {
  static get outlined => null;
}
