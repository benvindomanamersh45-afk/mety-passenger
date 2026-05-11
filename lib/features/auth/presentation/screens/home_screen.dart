import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metty_pro/core/theme/app_colors.dart';
import 'package:metty_pro/core/theme/app_gradients.dart';
import 'package:metty_pro/features/auth/passenger/presentation/widgets/city_chip.dart';
import 'package:metty_pro/features/auth/passenger/presentation/widgets/glass_card.dart';
import 'package:metty_pro/features/passenger/widgets/gradient_button.dart';
import 'package:metty_pro/core/api/api_client.dart';
import 'package:metty_pro/core/models/user_model.dart';
import 'package:metty_pro/core/models/trip_model.dart';

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
  int _bottomNavIndex = 0;

  User? _currentUser;
  List<Trip> _recentTrips = [];
  bool _isLoading = true;
  bool _isLoadingUser = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkLoginAndLoadData();
  }

  void _setupAnimations() {
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

  Future<void> _checkLoginAndLoadData() async {
    final isLoggedIn = await ApiClient.isLoggedIn();
    if (!isLoggedIn) {
      _redirectToLogin();
      return;
    }
    await _loadUserData();
    await _loadRecentTrips();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingUser = true;
    });

    try {
      final userData = await ApiClient.getCurrentUser();
      
      if (userData != null && userData.isNotEmpty) {
        setState(() {
          _currentUser = User.fromJson(userData);
          _isLoadingUser = false;
          _isLoading = false;
        });
        print('✅ Usuário carregado: ${_currentUser!.fullName}');
      } else {
        throw Exception('Dados do usuário não encontrados');
      }
    } catch (e) {
      print('❌ Erro ao carregar usuário: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoadingUser = false;
        _isLoading = false;
      });
      
      if (e.toString().contains('401') || e.toString().contains('Sessão')) {
        _redirectToLogin();
      }
    }
  }

  Future<void> _loadRecentTrips() async {
    try {
      final trips = await ApiClient.getTripHistory();
      setState(() {
        _recentTrips = trips.take(3).toList();
      });
    } catch (e) {
      print('Erro ao carregar viagens: $e');
    }
  }

  void _redirectToLogin() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _bottomNavIndex = index;
    });

    switch (index) {
      case 1: // Histórico
        Navigator.pushNamed(context, '/history').then((_) {
          setState(() => _bottomNavIndex = 0);
        });
        break;
      case 2: // Solicitar viagem
        Navigator.pushNamed(context, '/ride-request').then((_) {
          setState(() => _bottomNavIndex = 0);
        });
        break;
      case 3: // Perfil
        Navigator.pushNamed(context, '/profile').then((_) {
          setState(() => _bottomNavIndex = 0);
        });
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      body: Stack(
        children: [
          // Background gradiente
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

          // Conteúdo principal
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
                        horizontal: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: isVerySmallScreen
                                  ? 40
                                  : (isSmallScreen ? 50 : 60)),

                          // AppBar personalizada
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
                            child: GlassCard(
                              padding: EdgeInsets.all(isVerySmallScreen
                                  ? 12
                                  : (isSmallScreen ? 16 : 20)),
                              borderRadius: 20,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Logo e saudação
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: isVerySmallScreen
                                                  ? 28
                                                  : (isSmallScreen ? 30 : 32),
                                              height: isVerySmallScreen
                                                  ? 28
                                                  : (isSmallScreen ? 30 : 32),
                                              decoration: BoxDecoration(
                                                gradient: AppGradients.mety,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.directions_car_rounded,
                                                  color: AppColors.white,
                                                  size: isVerySmallScreen
                                                      ? 16
                                                      : (isSmallScreen
                                                          ? 18
                                                          : 20),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                width: isVerySmallScreen
                                                    ? 8
                                                    : (isSmallScreen
                                                        ? 10
                                                        : 12)),
                                            Flexible(
                                              child: Text(
                                                'METTY PRO',
                                                style: TextStyle(
                                                  fontSize: isVerySmallScreen
                                                      ? 14
                                                      : (isSmallScreen
                                                          ? 16
                                                          : 18),
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.white,
                                                  letterSpacing: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height: isVerySmallScreen
                                                ? 2
                                                : (isSmallScreen ? 4 : 6)),
                                        if (_isLoadingUser)
                                          Row(
                                            children: [
                                              Container(
                                                width: 12,
                                                height: 12,
                                                margin: const EdgeInsets.only(right: 6),
                                                child: const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppColors.metyBlue,
                                                ),
                                              ),
                                              const Text(
                                                'Carregando...',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          )
                                        else if (_currentUser != null)
                                          Text(
                                            'Olá, ${_currentUser!.firstName}! 👋',
                                            style: TextStyle(
                                              fontSize: isVerySmallScreen
                                                  ? 10
                                                  : (isSmallScreen ? 12 : 14),
                                              color: AppColors.white
                                                  .withOpacity(0.7),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(width: isVerySmallScreen ? 8 : 12),

                                  // Botão do perfil
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/profile');
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isVerySmallScreen
                                            ? 8
                                            : (isSmallScreen ? 10 : 12),
                                        vertical: isVerySmallScreen
                                            ? 4
                                            : (isSmallScreen ? 5 : 6),
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.metyBlue.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.metyBlue.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.person_rounded,
                                            color: AppColors.metyBlue,
                                            size: isVerySmallScreen
                                                ? 12
                                                : (isSmallScreen ? 13 : 14),
                                          ),
                                          SizedBox(
                                              width: isVerySmallScreen
                                                  ? 2
                                                  : (isSmallScreen ? 3 : 4)),
                                          Text(
                                            'PERFIL',
                                            style: TextStyle(
                                              fontSize: isVerySmallScreen
                                                  ? 8
                                                  : (isSmallScreen ? 9 : 10),
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.metyBlue,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(
                              height: isVerySmallScreen
                                  ? 16
                                  : (isSmallScreen ? 20 : 24)),

                          // Municípios disponíveis
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MUNICÍPIOS DISPONÍVEIS',
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen
                                        ? 10
                                        : (isSmallScreen ? 11 : 12),
                                    color: AppColors.white.withOpacity(0.6),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(
                                    height: isVerySmallScreen
                                        ? 8
                                        : (isSmallScreen ? 10 : 12)),
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
                                              ? 6
                                              : (isSmallScreen ? 8 : 10)),
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
                                              ? 6
                                              : (isSmallScreen ? 8 : 10)),
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
                                  ? 20
                                  : (isSmallScreen ? 24 : 30)),

                          // Dashboard cards
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _opacity.value,
                                child: Transform.translate(
                                  offset: Offset(0, _slideUp.value * 1.5),
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        title: 'VIAGENS',
                                        value: _currentUser != null
                                            ? '${_currentUser!.totalTrips}'
                                            : '0',
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
                                        value: _currentUser != null
                                            ? '${_currentUser!.rating.toStringAsFixed(1)}'
                                            : '0.0',
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
                                  ? 20
                                  : (isSmallScreen ? 24 : 30)),

                          // Botão principal - Solicitar viagem
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
                            child: Center(
                              child: GradientButton(
                                text: 'SOLICITAR VIAGEM',
                                onPressed: () {
                                  Navigator.pushNamed(context, '/ride-request');
                                },
                                gradient: AppGradients.mety,
                                icon: Icons.directions_car_filled_rounded,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isVerySmallScreen
                                      ? 16
                                      : (isSmallScreen ? 20 : 24),
                                  vertical: isVerySmallScreen
                                      ? 14
                                      : (isSmallScreen ? 16 : 18),
                                ),
                                isLoading: false,
                                fullWidth: false,
                                type: false,
                              ),
                            ),
                          ),

                          SizedBox(
                              height: isVerySmallScreen
                                  ? 20
                                  : (isSmallScreen ? 24 : 30)),

                          // Últimas viagens
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _opacity.value,
                                child: Transform.translate(
                                  offset: Offset(0, _slideUp.value * 2.0),
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ÚLTIMAS VIAGENS',
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen
                                        ? 12
                                        : (isSmallScreen ? 13 : 14),
                                    color: AppColors.white.withOpacity(0.6),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _recentTrips.isEmpty
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.history_rounded,
                                                size: 50,
                                                color: Colors.white24,
                                              ),
                                              const SizedBox(height: 10),
                                              const Text(
                                                'Nenhuma viagem recente',
                                                style: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Column(
                                        children: _recentTrips.map((trip) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: GlassCard(
                                              padding: const EdgeInsets.all(12),
                                              borderRadius: 15,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.metyBlue.withOpacity(0.2),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: const Icon(
                                                      Icons.directions_car,
                                                      color: AppColors.metyBlue,
                                                      size: 24,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          trip.destinationAddress,
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          '${trip.price.toStringAsFixed(0)} Kz',
                                                          style: const TextStyle(
                                                            color: AppColors.metyGreen,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: trip.status == 'COMPLETED'
                                                          ? AppColors.metyGreen.withOpacity(0.2)
                                                          : AppColors.metyOrange.withOpacity(0.2),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      trip.statusDisplay,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: trip.status == 'COMPLETED'
                                                            ? AppColors.metyGreen
                                                            : AppColors.metyOrange,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 80),
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
              padding: EdgeInsets.symmetric(
                horizontal: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20),
                vertical: isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14),
              ),
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.95),
                border: Border(
                  top: BorderSide(
                    color: AppColors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.home_rounded,
                    label: 'Início',
                    index: 0,
                    isVerySmallScreen: isVerySmallScreen,
                    isSmallScreen: isSmallScreen,
                  ),
                  _buildNavItem(
                    icon: Icons.history_rounded,
                    label: 'Histórico',
                    index: 1,
                    isVerySmallScreen: isVerySmallScreen,
                    isSmallScreen: isSmallScreen,
                  ),
                  _buildNavItem(
                    icon: Icons.directions_car_rounded,
                    label: 'Viajar',
                    index: 2,
                    isVerySmallScreen: isVerySmallScreen,
                    isSmallScreen: isSmallScreen,
                  ),
                  _buildNavItem(
                    icon: Icons.person_rounded,
                    label: 'Perfil',
                    index: 3,
                    isVerySmallScreen: isVerySmallScreen,
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isVerySmallScreen,
    required bool isSmallScreen,
  }) {
    final isSelected = _bottomNavIndex == index;
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? AppColors.metyBlue
                : AppColors.white.withOpacity(0.5),
            size: isVerySmallScreen ? 20 : (isSmallScreen ? 21 : 22),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: isVerySmallScreen ? 8 : (isSmallScreen ? 9 : 10),
              color: isSelected
                  ? AppColors.metyBlue
                  : AppColors.white.withOpacity(0.5),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
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
                const SizedBox(width: 2),
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
}
