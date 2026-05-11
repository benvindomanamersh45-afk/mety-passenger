// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metty_pro/core/theme/app_colors.dart';
import 'package:metty_pro/core/theme/app_gradients.dart';
import 'package:metty_pro/features/auth/passenger/presentation/widgets/city_chip.dart';
import 'package:metty_pro/features/auth/passenger/presentation/widgets/glass_card.dart';
//import 'package:metty_pro/features/passenger/widgets/glass_card.dart';
import 'package:metty_pro/features/passenger/widgets/gradient_button.dart';
//import 'package:metty_pro/features/passenger/widgets/city_chip.dart';
import 'package:metty_pro/shared/widgets/custom_app_bar.dart';
//import 'package:metty_pro/shared/widgets/bottom_nav_bar.dart';
import 'package:metty_pro/features/passenger/presentation/screens/ride_request_map_screen.dart'; // ← IMPORT ADICIONADO

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _slideUp;
  int _selectedTab = 0;
  int _bottomNavIndex = 0; // Índice para a BottomNavBar

  final List<Map<String, dynamic>> _recentRides = [
    {
      'id': '1',
      'from': 'Aeroporto de Saurimo',
      'to': 'Hotel Chik',
      'date': 'Hoje, 14:30',
      'price': '2.500 Kz',
      'status': 'Concluída',
      'driver': 'João M.',
      'rating': 5.0,
    },
    {
      'id': '2',
      'from': 'Mercado Municipal',
      'to': 'Cassengo Center',
      'date': 'Ontem, 10:15',
      'price': '1.800 Kz',
      'status': 'Concluída',
      'driver': 'Maria L.',
      'rating': 4.8,
    },
    {
      'id': '3',
      'from': 'Muangueji Plaza',
      'to': 'Clínica Esperança',
      'date': '15/12, 08:45',
      'price': '2.100 Kz',
      'status': 'Concluída',
      'driver': 'Pedro K.',
      'rating': 4.9,
    },
  ];

  final List<Map<String, dynamic>> _availableDrivers = [
    {
      'id': '1',
      'name': 'Carlos Silva',
      'car': 'Toyota Prado',
      'plate': 'LD-01-45-AB',
      'rating': 4.9,
      'distance': '0.8 km',
      'eta': '3 min',
      'price': '2.500 Kz',
      'color': AppColors.metyBlue,
    },
    {
      'id': '2',
      'name': 'Ana Santos',
      'car': 'Mercedes V-Class',
      'plate': 'LD-01-67-CD',
      'rating': 4.8,
      'distance': '1.2 km',
      'eta': '5 min',
      'price': '2.800 Kz',
      'color': AppColors.metyGreen,
    },
    {
      'id': '3',
      'name': 'Miguel Costa',
      'car': 'BMW X5',
      'plate': 'LD-01-89-EF',
      'rating': 5.0,
      'distance': '0.5 km',
      'eta': '2 min',
      'price': '3.000 Kz',
      'color': AppColors.metyOrange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _slideUp = Tween<double>(begin: 30.0, end: 0.0).animate(
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

  void _onBottomNavTap(int index) {
    setState(() {
      _bottomNavIndex = index;
    });

    switch (index) {
      case 0: // Home (já está aqui)
        break;
      case 1: // Histórico
        Navigator.pushNamed(context, '/history');
        // Volta o índice para 0 quando voltar
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => _bottomNavIndex = 0);
        });
        break;
      case 2: // Solicitar viagem (agora usando a nova tela com mapa)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RideRequestMapScreen()),
        ).then((_) {
          setState(() => _bottomNavIndex = 0);
        });
        break;
      case 3: // Perfil
        Navigator.pushNamed(context, '/profile');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => _bottomNavIndex = 0);
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isVerySmallScreen = screenWidth < 360;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.black,
      // Usando MinimalAppBar (sem título, apenas botões)
      appBar: MinimalAppBar(
        showBackButton: false,
        showProfileButton: true,
        onProfilePressed: () {
          Navigator.pushNamed(context, '/profile');
        },
      ),
      body: Stack(
        children: [
          // Background gradiente METY
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.5,
                  colors: [
                    AppColors.metyBlue.withOpacity(0.1),
                    AppColors.black,
                  ],
                  stops: const [0.0, 0.8],
                ),
              ),
            ),
          ),

          // Conteúdo principal COM LAYOUT RESPONSIVO
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: isVerySmallScreen
                                  ? 20
                                  : (isSmallScreen ? 30 : 40)),

                          // Saudação
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _opacity.value,
                                child: Transform.translate(
                                  offset: Offset(0, _slideUp.value),
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Olá, João! 👋',
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen
                                        ? 24
                                        : (isSmallScreen ? 26 : 28),
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.white,
                                  ),
                                ),
                                SizedBox(
                                    height: isVerySmallScreen
                                        ? 4
                                        : (isSmallScreen ? 6 : 8)),
                                Text(
                                  'Pronto para sua próxima viagem?',
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen
                                        ? 12
                                        : (isSmallScreen ? 13 : 14),
                                    color: AppColors.white.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                              height: isVerySmallScreen
                                  ? 24
                                  : (isSmallScreen ? 28 : 32)),

                          // Card de solicitação rápida
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _opacity.value,
                                child: Transform.translate(
                                  offset: Offset(0, _slideUp.value * 1.2),
                                  child: child,
                                ),
                              );
                            },
                            child: GlassCard(
                              padding: EdgeInsets.all(isVerySmallScreen
                                  ? 16
                                  : (isSmallScreen ? 18 : 20)),
                              borderRadius: 20,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: isVerySmallScreen
                                            ? 44
                                            : (isSmallScreen ? 48 : 52),
                                        height: isVerySmallScreen
                                            ? 44
                                            : (isSmallScreen ? 48 : 52),
                                        decoration: BoxDecoration(
                                          gradient: AppGradients.mety,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.directions_car_filled_rounded,
                                          color: AppColors.white,
                                          size: isVerySmallScreen
                                              ? 22
                                              : (isSmallScreen ? 24 : 26),
                                        ),
                                      ),
                                      SizedBox(
                                          width: isVerySmallScreen
                                              ? 12
                                              : (isSmallScreen ? 14 : 16)),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'VIAGEM RÁPIDA',
                                              style: TextStyle(
                                                fontSize: isVerySmallScreen
                                                    ? 14
                                                    : (isSmallScreen ? 15 : 16),
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.white,
                                              ),
                                            ),
                                            SizedBox(
                                                height: isVerySmallScreen
                                                    ? 2
                                                    : (isSmallScreen ? 4 : 6)),
                                            Text(
                                              'Solicite uma viagem em poucos toques',
                                              style: TextStyle(
                                                fontSize: isVerySmallScreen
                                                    ? 11
                                                    : (isSmallScreen ? 12 : 13),
                                                color: AppColors.white
                                                    .withOpacity(0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height: isVerySmallScreen
                                          ? 16
                                          : (isSmallScreen ? 18 : 20)),
                                  GradientButton(
                                    text: 'SOLICITAR VIAGEM',
                                    // ===== BOTÃO CORRIGIDO PARA USAR A NOVA TELA COM MAPA =====
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const RideRequestMapScreen(),
                                        ),
                                      );
                                    },
                                    gradient: AppGradients.mety,
                                    icon: Icons.arrow_forward_rounded,
                                    fullWidth: true,
                                    type: null,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(
                              height: isVerySmallScreen
                                  ? 24
                                  : (isSmallScreen ? 28 : 32)),

                          // Municípios disponíveis
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _opacity.value,
                                child: Transform.translate(
                                  offset: Offset(0, _slideUp.value * 1.4),
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MUNICÍPIOS DISPONÍVEIS',
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen
                                        ? 12
                                        : (isSmallScreen ? 13 : 14),
                                    color: AppColors.white.withOpacity(0.6),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(
                                    height: isVerySmallScreen
                                        ? 12
                                        : (isSmallScreen ? 14 : 16)),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    children: [
                                      CityChip(
                                        city: 'SAURIMO',
                                        color: AppColors.metyBlue,
                                        icon: Icons.location_city,
                                        glowing: true,
                                        isActive: true,
                                        isSmall: isVerySmallScreen,
                                        isSelected: false,
                                        onTap: () {},
                                        isSmallScreen: isSmallScreen,
                                        isVerySmallScreen: isVerySmallScreen,
                                      ),
                                      SizedBox(
                                          width: isVerySmallScreen
                                              ? 8
                                              : (isSmallScreen ? 10 : 12)),
                                      CityChip(
                                        city: 'CASSENGO',
                                        color: AppColors.metyGreen,
                                        icon: Icons.landscape,
                                        glowing: true,
                                        isActive: false,
                                        isSmall: isVerySmallScreen,
                                        isSelected: false,
                                        onTap: () {},
                                        isSmallScreen: isSmallScreen,
                                        isVerySmallScreen: isVerySmallScreen,
                                      ),
                                      SizedBox(
                                          width: isVerySmallScreen
                                              ? 8
                                              : (isSmallScreen ? 10 : 12)),
                                      CityChip(
                                        city: 'MUANGUEJI',
                                        color: AppColors.metyOrange,
                                        icon: Icons.nature,
                                        glowing: true,
                                        isActive: false,
                                        isSmall: isVerySmallScreen,
                                        isSelected: false,
                                        onTap: () {},
                                        isSmallScreen: isSmallScreen,
                                        isVerySmallScreen: isVerySmallScreen,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                              height: isVerySmallScreen
                                  ? 24
                                  : (isSmallScreen ? 28 : 32)),

                          // Dashboard cards
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _opacity.value,
                                child: Transform.translate(
                                  offset: Offset(0, _slideUp.value * 1.6),
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                // Cards de estatísticas
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        title: 'VIAGENS',
                                        value: '47',
                                        icon: Icons.directions_car_rounded,
                                        color: AppColors.metyBlue,
                                        isVerySmallScreen: isVerySmallScreen,
                                        isSmallScreen: isSmallScreen,
                                      ),
                                    ),
                                    SizedBox(
                                        width: isVerySmallScreen
                                            ? 8
                                            : (isSmallScreen ? 10 : 12)),
                                    Expanded(
                                      child: _buildStatCard(
                                        title: 'AVALIAÇÃO',
                                        value: '4.9',
                                        icon: Icons.star_rounded,
                                        color: AppColors.metyOrange,
                                        isVerySmallScreen: isVerySmallScreen,
                                        isSmallScreen: isSmallScreen,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                    height: isVerySmallScreen
                                        ? 8
                                        : (isSmallScreen ? 10 : 12)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        title: 'TEMPO MÉDIO',
                                        value: '3.2',
                                        unit: 'min',
                                        icon: Icons.timer_rounded,
                                        color: AppColors.metyGreen,
                                        isVerySmallScreen: isVerySmallScreen,
                                        isSmallScreen: isSmallScreen,
                                      ),
                                    ),
                                    SizedBox(
                                        width: isVerySmallScreen
                                            ? 8
                                            : (isSmallScreen ? 10 : 12)),
                                    Expanded(
                                      child: _buildStatCard(
                                        title: 'ECONOMIZOU',
                                        value: '12.5',
                                        unit: 'K',
                                        icon: Icons.savings_rounded,
                                        color: AppColors.metyBlueLight,
                                        isVerySmallScreen: isVerySmallScreen,
                                        isSmallScreen: isSmallScreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                              height: isVerySmallScreen
                                  ? 24
                                  : (isSmallScreen ? 28 : 32)),

                          // Tabs para Motoristas/Histórico
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _opacity.value,
                                child: Transform.translate(
                                  offset: Offset(0, _slideUp.value * 1.8),
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tabs
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedTab = 0;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: isVerySmallScreen
                                                    ? 10
                                                    : (isSmallScreen
                                                        ? 12
                                                        : 14)),
                                            decoration: BoxDecoration(
                                              color: _selectedTab == 0
                                                  ? AppColors.metyBlue
                                                      .withOpacity(0.2)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'MOTORISTAS',
                                                style: TextStyle(
                                                  fontSize: isVerySmallScreen
                                                      ? 10
                                                      : (isSmallScreen
                                                          ? 11
                                                          : 12),
                                                  fontWeight: FontWeight.w600,
                                                  color: _selectedTab == 0
                                                      ? AppColors.metyBlue
                                                      : AppColors.white
                                                          .withOpacity(0.6),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedTab = 1;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: isVerySmallScreen
                                                    ? 10
                                                    : (isSmallScreen
                                                        ? 12
                                                        : 14)),
                                            decoration: BoxDecoration(
                                              color: _selectedTab == 1
                                                  ? AppColors.metyBlue
                                                      .withOpacity(0.2)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'HISTÓRICO',
                                                style: TextStyle(
                                                  fontSize: isVerySmallScreen
                                                      ? 10
                                                      : (isSmallScreen
                                                          ? 11
                                                          : 12),
                                                  fontWeight: FontWeight.w600,
                                                  color: _selectedTab == 1
                                                      ? AppColors.metyBlue
                                                      : AppColors.white
                                                          .withOpacity(0.6),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                    height: isVerySmallScreen
                                        ? 16
                                        : (isSmallScreen ? 20 : 24)),

                                // Conteúdo da tab selecionada
                                if (_selectedTab == 0)
                                  _buildDriversList(
                                      isVerySmallScreen, isSmallScreen)
                                else
                                  _buildHistoryList(
                                      isVerySmallScreen, isSmallScreen),
                              ],
                            ),
                          ),

                          SizedBox(
                              height: isVerySmallScreen
                                  ? 30
                                  : (isSmallScreen ? 40 : 50)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.95),
                border: Border(
                  top: BorderSide(
                    color: AppColors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home_rounded, 'Início', 0),
                    _buildNavItem(Icons.history_rounded, 'Histórico', 1),
                    _buildNavItem(Icons.directions_car_rounded, 'Viajar', 2),
                    _buildNavItem(Icons.person_rounded, 'Perfil', 3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _bottomNavIndex == index;
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.metyBlue : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.metyBlue : Colors.grey,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isVerySmallScreen,
    required bool isSmallScreen,
    String unit = '',
  }) {
    return GlassCard(
      padding:
          EdgeInsets.all(isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16)),
      borderRadius: 15,
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isVerySmallScreen ? 32 : (isSmallScreen ? 34 : 36),
            height: isVerySmallScreen ? 32 : (isSmallScreen ? 34 : 36),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: isVerySmallScreen ? 16 : (isSmallScreen ? 17 : 18),
              ),
            ),
          ),
          SizedBox(height: isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isVerySmallScreen ? 18 : (isSmallScreen ? 20 : 22),
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  height: 0.9,
                ),
              ),
              if (unit.isNotEmpty) ...[
                SizedBox(width: 2),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: isVerySmallScreen ? 3 : (isSmallScreen ? 4 : 5)),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize:
                          isVerySmallScreen ? 10 : (isSmallScreen ? 11 : 12),
                      color: AppColors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: isVerySmallScreen ? 2 : (isSmallScreen ? 3 : 4)),
          Text(
            title,
            style: TextStyle(
              fontSize: isVerySmallScreen ? 9 : (isSmallScreen ? 10 : 11),
              color: AppColors.white.withOpacity(0.6),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriversList(bool isVerySmallScreen, bool isSmallScreen) {
    return Column(
      children: [
        for (var driver in _availableDrivers)
          Padding(
            padding: EdgeInsets.only(
                bottom: isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14)),
            child: GlassCard(
              padding: EdgeInsets.all(
                  isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16)),
              borderRadius: 15,
              onTap: () {
                // Selecionar motorista
              },
              child: Row(
                children: [
                  // Avatar do motorista
                  Container(
                    width: isVerySmallScreen ? 44 : (isSmallScreen ? 48 : 52),
                    height: isVerySmallScreen ? 44 : (isSmallScreen ? 48 : 52),
                    decoration: BoxDecoration(
                      gradient: AppGradients.mety,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: AppColors.white,
                        size:
                            isVerySmallScreen ? 20 : (isSmallScreen ? 22 : 24),
                      ),
                    ),
                  ),
                  SizedBox(
                      width:
                          isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver['name'],
                          style: TextStyle(
                            fontSize: isVerySmallScreen
                                ? 12
                                : (isSmallScreen ? 13 : 14),
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                            height: isVerySmallScreen
                                ? 2
                                : (isSmallScreen ? 3 : 4)),
                        Text(
                          '${driver['car']}',
                          style: TextStyle(
                            fontSize: isVerySmallScreen
                                ? 9
                                : (isSmallScreen ? 10 : 11),
                            color: AppColors.white.withOpacity(0.7),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                            height: isVerySmallScreen
                                ? 4
                                : (isSmallScreen ? 5 : 6)),
                        Wrap(
                          spacing:
                              isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12),
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: AppColors.metyOrange,
                                  size: isVerySmallScreen
                                      ? 12
                                      : (isSmallScreen ? 13 : 14),
                                ),
                                SizedBox(width: 2),
                                Text(
                                  driver['rating'].toString(),
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen
                                        ? 10
                                        : (isSmallScreen ? 11 : 12),
                                    color: AppColors.metyOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.metyGreen,
                                  size: isVerySmallScreen
                                      ? 12
                                      : (isSmallScreen ? 13 : 14),
                                ),
                                SizedBox(width: 2),
                                Text(
                                  driver['distance'],
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen
                                        ? 10
                                        : (isSmallScreen ? 11 : 12),
                                    color: AppColors.metyGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        driver['eta'],
                        style: TextStyle(
                          fontSize: isVerySmallScreen
                              ? 14
                              : (isSmallScreen ? 16 : 18),
                          fontWeight: FontWeight.w800,
                          color: AppColors.metyBlue,
                        ),
                      ),
                      SizedBox(
                          height:
                              isVerySmallScreen ? 2 : (isSmallScreen ? 3 : 4)),
                      Text(
                        driver['price'],
                        style: TextStyle(
                          fontSize: isVerySmallScreen
                              ? 12
                              : (isSmallScreen ? 13 : 14),
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHistoryList(bool isVerySmallScreen, bool isSmallScreen) {
    return Column(
      children: [
        for (var ride in _recentRides)
          Padding(
            padding: EdgeInsets.only(
                bottom: isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14)),
            child: GlassCard(
              padding: EdgeInsets.all(
                  isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16)),
              borderRadius: 15,
              onTap: () {
                // Ver detalhes da viagem
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          ride['date'],
                          style: TextStyle(
                            fontSize: isVerySmallScreen
                                ? 10
                                : (isSmallScreen ? 11 : 12),
                            color: AppColors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              isVerySmallScreen ? 8 : (isSmallScreen ? 9 : 10),
                          vertical:
                              isVerySmallScreen ? 3 : (isSmallScreen ? 4 : 5),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.metyGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.metyGreen.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          ride['status'],
                          style: TextStyle(
                            fontSize: isVerySmallScreen
                                ? 8
                                : (isSmallScreen ? 9 : 10),
                            color: AppColors.metyGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height:
                          isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14)),
                  Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.metyBlue,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          Container(
                            width: 2,
                            height: isVerySmallScreen
                                ? 36
                                : (isSmallScreen ? 40 : 44),
                            color: AppColors.white.withOpacity(0.3),
                            margin: EdgeInsets.symmetric(vertical: 4),
                          ),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.metyGreen,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          width: isVerySmallScreen
                              ? 10
                              : (isSmallScreen ? 12 : 14)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride['from'],
                              style: TextStyle(
                                fontSize: isVerySmallScreen
                                    ? 11
                                    : (isSmallScreen ? 12 : 13),
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                                height: isVerySmallScreen
                                    ? 6
                                    : (isSmallScreen ? 8 : 10)),
                            Text(
                              ride['to'],
                              style: TextStyle(
                                fontSize: isVerySmallScreen
                                    ? 11
                                    : (isSmallScreen ? 12 : 13),
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height:
                          isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14)),
                  Divider(
                    color: AppColors.white.withOpacity(0.1),
                    height: 1,
                  ),
                  SizedBox(
                      height:
                          isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: isVerySmallScreen
                                ? 14
                                : (isSmallScreen ? 15 : 16),
                            color: AppColors.white.withOpacity(0.6),
                          ),
                          SizedBox(width: 4),
                          Text(
                            ride['driver'],
                            style: TextStyle(
                              fontSize: isVerySmallScreen
                                  ? 10
                                  : (isSmallScreen ? 11 : 12),
                              color: AppColors.white.withOpacity(0.7),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: isVerySmallScreen
                                ? 14
                                : (isSmallScreen ? 15 : 16),
                            color: AppColors.metyOrange,
                          ),
                          SizedBox(width: 4),
                          Text(
                            ride['rating'].toString(),
                            style: TextStyle(
                              fontSize: isVerySmallScreen
                                  ? 10
                                  : (isSmallScreen ? 11 : 12),
                              color: AppColors.metyOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                              width: isVerySmallScreen
                                  ? 12
                                  : (isSmallScreen ? 16 : 20)),
                          Text(
                            ride['price'],
                            style: TextStyle(
                              fontSize: isVerySmallScreen
                                  ? 12
                                  : (isSmallScreen ? 13 : 14),
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
}
