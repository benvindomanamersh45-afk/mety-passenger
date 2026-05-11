import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metty_pro/core/theme/app_colors.dart';
import 'package:metty_pro/core/theme/app_gradients.dart';
import 'package:metty_pro/features/auth/passenger/presentation/widgets/glass_card.dart';
import 'package:metty_pro/features/passenger/widgets/gradient_button.dart';
import 'package:metty_pro/core/api/api_client.dart';
import 'package:metty_pro/core/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _slideUp;

  User? _user;
  bool _isLoading = true;
  String? _errorMessage;

  // Controladores para edição de perfil
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  // Controladores para alterar senha
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;
  bool _changingPassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Dados mockados (mantidos para fallback)
  final List<Map<String, dynamic>> _savedPaymentMethods = [
    {
      'id': 0,
      'type': 'Cartão de Crédito',
      'lastFour': '**** 4321',
      'icon': Icons.credit_card_rounded,
      'color': AppColors.metyBlue,
    },
    {
      'id': 1,
      'type': 'MPesa',
      'lastFour': '944 123 456',
      'icon': Icons.phone_android_rounded,
      'color': AppColors.metyOrange,
    },
  ];

  final List<Map<String, dynamic>> _travelPreferences = [
    {
      'id': 0,
      'title': 'Veículo Preferido',
      'value': 'PREMIUM',
      'icon': Icons.directions_car_filled_rounded,
      'color': AppColors.metyOrange,
    },
    {
      'id': 1,
      'title': 'Música durante a viagem',
      'value': 'Ligada',
      'icon': Icons.music_note_rounded,
      'color': AppColors.metyBlue,
    },
    {
      'id': 2,
      'title': 'Conversa com motorista',
      'value': 'Opcional',
      'icon': Icons.chat_rounded,
      'color': AppColors.metyGreen,
    },
  ];

  final List<Map<String, dynamic>> _settingsOptions = [
    {
      'id': 0,
      'title': 'Notificações',
      'icon': Icons.notifications_rounded,
      'color': AppColors.metyOrange,
      'enabled': true,
    },
    {
      'id': 1,
      'title': 'Privacidade',
      'icon': Icons.lock_rounded,
      'color': AppColors.metyBlue,
    },
    {
      'id': 2,
      'title': 'Idioma',
      'icon': Icons.language_rounded,
      'color': AppColors.metyBlue,
      'value': 'Português',
    },
    {
      'id': 3,
      'title': 'Tema',
      'icon': Icons.dark_mode_rounded,
      'color': AppColors.metyGreen,
      'value': 'Escuro',
    },
  ];

  final List<Map<String, dynamic>> _supportOptions = [
    {
      'id': 0,
      'title': 'Central de Ajuda',
      'icon': Icons.help_center_rounded,
      'color': AppColors.metyBlue,
    },
    {
      'id': 1,
      'title': 'Contatar Suporte',
      'icon': Icons.support_agent_rounded,
      'color': AppColors.metyGreen,
    },
    {
      'id': 2,
      'title': 'Termos de Uso',
      'icon': Icons.description_rounded,
      'color': AppColors.white,
    },
    {
      'id': 3,
      'title': 'Política de Privacidade',
      'icon': Icons.shield_rounded,
      'color': AppColors.metyOrange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserData();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    _slideUp = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  Future<void> _loadUserData() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    // Verificar se está logado primeiro
    final isLogged = await ApiClient.isLoggedIn();
    print('📱 Usuário logado? $isLogged');
    
    if (!isLogged) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    print('📡 Buscando dados do usuário...');
    final userData = await ApiClient.getCurrentUser();
    print('📦 Resposta: $userData');
    
    if (userData != null && userData.isNotEmpty) {
      setState(() {
        _user = User.fromJson(userData);
        _nameController.text = _user!.fullName;
        _emailController.text = _user!.email;
        _phoneController.text = _user!.phone.replaceAll('+244', '');
        _birthDateController.text = _user!.birthDate ?? '';
        _isLoading = false;
      });
      print('✅ Perfil carregado com sucesso!');
    } else {
      throw Exception('Dados do usuário não encontrados');
    }
  } catch (e) {
    print('❌ Erro ao carregar perfil: $e');
    setState(() {
      _errorMessage = e.toString();
      _isLoading = false;
    });
    
    // Se erro de autenticação, redirecionar para login
    if (e.toString().contains('401') || e.toString().contains('Sessão expirada')) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    }
  }
}

  // ===== MÉTODO PARA SALVAR PERFIL =====
  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      _showErrorSnackbar('O nome não pode estar vazio');
      return;
    }

    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showErrorSnackbar('Email inválido');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final nameParts = _nameController.text.trim().split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      final fullPhone = '+244$cleanPhone';

      final updateData = {
        'first_name': firstName,
        'last_name': lastName,
        'email': _emailController.text,
        'phone': fullPhone,
        'birth_date': _birthDateController.text,
      };

      print('📝 Enviando: $updateData');
      
      final response = await ApiClient.updateProfile(updateData);
      
      if (response != null) {
        setState(() {
          _user = User.fromJson(response);
          _isEditing = false;
          _isSaving = false;
        });
        
        _showSuccessSnackbar('Perfil atualizado com sucesso!');
      } else {
        throw Exception('Erro ao atualizar');
      }
      
    } catch (e) {
      print('❌ Erro: $e');
      setState(() => _isSaving = false);
      _showErrorSnackbar('Erro ao atualizar perfil');
    }
  }

  // ===== MÉTODO PARA ALTERAR SENHA =====
  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty) {
      _showErrorSnackbar('Digite a senha atual');
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showErrorSnackbar('A nova senha deve ter pelo menos 6 caracteres');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorSnackbar('As senhas não coincidem');
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Simular alteração de senha (implementar com API real depois)
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _changingPassword = false;
        _isSaving = false;
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });
      
      _showSuccessSnackbar('Senha alterada com sucesso!');
      
    } catch (e) {
      setState(() => _isSaving = false);
      _showErrorSnackbar('Erro ao alterar senha');
    }
  }

  Future<void> _logout() async {
    await ApiClient.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: AppColors.metyBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          title: Text(
            'SAIR DA CONTA',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.metyBlue,
            ),
          ),
          content: Text(
            'Tem certeza que deseja sair?',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.white.withOpacity(0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCELAR',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _logout();
              },
              child: Text(
                'SAIR',
                style: TextStyle(
                  color: AppColors.metyOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                        horizontal: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: isVerySmallScreen ? 50 : (isSmallScreen ? 60 : 70),
                          ),

                          // App Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: isVerySmallScreen ? 36 : (isSmallScreen ? 38 : 40),
                                  height: isVerySmallScreen ? 36 : (isSmallScreen ? 38 : 40),
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
                                    size: isVerySmallScreen ? 18 : (isSmallScreen ? 19 : 20),
                                  ),
                                ),
                              ),
                              if (!_isLoading && _user != null && !_isEditing && !_changingPassword)
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _isEditing = true);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isVerySmallScreen ? 12 : 16,
                                      vertical: isVerySmallScreen ? 8 : 10,
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
                                          Icons.edit_rounded,
                                          color: AppColors.metyBlue,
                                          size: isVerySmallScreen ? 14 : 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'EDITAR',
                                          style: TextStyle(
                                            fontSize: isVerySmallScreen ? 11 : 12,
                                            color: AppColors.metyBlue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Título
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
                                  'MEU PERFIL',
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen ? 22 : (isSmallScreen ? 24 : 28),
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _errorMessage ?? 'Gerencie sua conta e preferências',
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14),
                                    color: _errorMessage != null
                                        ? AppColors.metyOrange
                                        : AppColors.white.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Card de perfil
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
                              padding: EdgeInsets.all(
                                isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
                              ),
                              borderRadius: 20,
                              child: _buildProfileContent(
                                isVerySmallScreen,
                                isSmallScreen,
                              ),
                            ),
                          ),

                          if (!_isLoading && _user != null && !_changingPassword) ...[
                            const SizedBox(height: 24),

                            // Botão para alterar senha
                            if (!_isEditing)
                              Center(
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() => _changingPassword = true);
                                  },
                                  icon: const Icon(Icons.lock_reset_rounded, color: AppColors.metyBlue),
                                  label: const Text(
                                    'Alterar Senha',
                                    style: TextStyle(color: AppColors.metyBlue),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 24),

                            // Métodos de pagamento
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
                              child: _buildPaymentMethods(isVerySmallScreen, isSmallScreen),
                            ),

                            const SizedBox(height: 24),

                            // Preferências de viagem
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
                              child: _buildTravelPreferences(isVerySmallScreen, isSmallScreen),
                            ),

                            const SizedBox(height: 24),

                            // Configurações
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
                              child: _buildSettings(isVerySmallScreen, isSmallScreen),
                            ),

                            const SizedBox(height: 24),

                            // Suporte
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
                              child: _buildSupport(isVerySmallScreen, isSmallScreen),
                            ),

                            const SizedBox(height: 24),

                            // Botão de logout
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _opacity.value,
                                  child: Transform.translate(
                                    offset: Offset(0, _slideUp.value * 2.2),
                                    child: child,
                                  ),
                                );
                              },
                              child: Center(
                                child: GradientButton(
                                  text: 'SAIR DA CONTA',
                                  onPressed: _showLogoutDialog,
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.metyOrange,
                                      AppColors.metyOrange,
                                    ],
                                  ),
                                  icon: Icons.logout_rounded,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isVerySmallScreen ? 24 : 32,
                                    vertical: isVerySmallScreen ? 16 : 20,
                                  ),
                                  fullWidth: false,
                                  type: null,
                                ),
                              ),
                            ),
                          ],

                          if (_changingPassword) ...[
                            const SizedBox(height: 24),
                            _buildPasswordChangeCard(isVerySmallScreen, isSmallScreen),
                          ],

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(bool isVerySmallScreen, bool isSmallScreen) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: AppColors.metyBlue),
        ),
      );
    }

    if (_user == null) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.error_rounded,
              size: 50,
              color: AppColors.error,
            ),
            const SizedBox(height: 10),
            Text(
              'Erro ao carregar perfil',
              style: TextStyle(
                color: AppColors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('TENTAR NOVAMENTE'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Avatar
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: isVerySmallScreen ? 80 : (isSmallScreen ? 90 : 100),
              height: isVerySmallScreen ? 80 : (isSmallScreen ? 90 : 100),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.mety,
              ),
              child: Center(
                child: Text(
                  _user!.firstName[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 32 : (isSmallScreen ? 36 : 40),
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        if (_isEditing) ...[
          // Modo edição - campos completos
          _buildEditableField(
            label: 'Nome Completo',
            controller: _nameController,
            icon: Icons.person_rounded,
            isVerySmallScreen: isVerySmallScreen,
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 12),
          _buildEditableField(
            label: 'E-mail',
            controller: _emailController,
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            isVerySmallScreen: isVerySmallScreen,
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 12),
          _buildPhoneField(
            label: 'Telefone',
            controller: _phoneController,
            isVerySmallScreen: isVerySmallScreen,
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 12),
          _buildEditableField(
            label: 'Data de Nascimento',
            controller: _birthDateController,
            icon: Icons.cake_rounded,
            isVerySmallScreen: isVerySmallScreen,
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  text: 'CANCELAR',
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _nameController.text = _user!.fullName;
                      _emailController.text = _user!.email;
                      _phoneController.text = _user!.phone.replaceAll('+244', '');
                      _birthDateController.text = _user!.birthDate ?? '';
                    });
                  },
                  gradient: const LinearGradient(
                    colors: [Colors.grey, Colors.grey],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  fullWidth: true,
                  type: null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  text: _isSaving ? 'SALVANDO...' : 'SALVAR',
                  onPressed: _isSaving ? null : _saveProfile,
                  gradient: AppGradients.mety,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  fullWidth: true,
                  type: null,
                ),
              ),
            ],
          ),
        ] else ...[
          // Modo visualização - todos os campos
          Text(
            _user!.fullName,
            style: TextStyle(
              fontSize: isVerySmallScreen ? 18 : (isSmallScreen ? 20 : 22),
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user!.email,
            style: TextStyle(
              fontSize: isVerySmallScreen ? 13 : (isSmallScreen ? 14 : 15),
              color: AppColors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _user!.phone,
            style: TextStyle(
              fontSize: isVerySmallScreen ? 13 : (isSmallScreen ? 14 : 15),
              color: AppColors.white.withOpacity(0.7),
            ),
          ),
          if (_user!.birthDate != null && _user!.birthDate!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Nascimento: ${_user!.birthDate}',
              style: TextStyle(
                fontSize: isVerySmallScreen ? 13 : (isSmallScreen ? 14 : 15),
                color: AppColors.white.withOpacity(0.7),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isVerySmallScreen ? 12 : 16,
              vertical: isVerySmallScreen ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: _user!.userType == 'DRIVER'
                  ? AppColors.metyOrange.withOpacity(0.2)
                  : AppColors.metyGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _user!.userType == 'DRIVER'
                    ? AppColors.metyOrange.withOpacity(0.3)
                    : AppColors.metyGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _user!.userType == 'DRIVER'
                      ? Icons.drive_eta_rounded
                      : Icons.person_rounded,
                  size: isVerySmallScreen ? 14 : 16,
                  color: _user!.userType == 'DRIVER'
                      ? AppColors.metyOrange
                      : AppColors.metyGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  _user!.userType == 'DRIVER' ? 'Motorista' : 'Passageiro',
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 11 : 12,
                    color: _user!.userType == 'DRIVER'
                        ? AppColors.metyOrange
                        : AppColors.metyGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordChangeCard(bool isVerySmallScreen, bool isSmallScreen) {
    return GlassCard(
      padding: EdgeInsets.all(isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20)),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ALTERAR SENHA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white54),
                onPressed: () {
                  setState(() {
                    _changingPassword = false;
                    _currentPasswordController.clear();
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Senha atual
          _buildPasswordField(
            label: 'Senha Atual',
            controller: _currentPasswordController,
            isPasswordVisible: !_obscureCurrentPassword,
            onToggleVisibility: () {
              setState(() => _obscureCurrentPassword = !_obscureCurrentPassword);
            },
            isVerySmallScreen: isVerySmallScreen,
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 12),

          // Nova senha
          _buildPasswordField(
            label: 'Nova Senha',
            controller: _newPasswordController,
            isPasswordVisible: !_obscureNewPassword,
            onToggleVisibility: () {
              setState(() => _obscureNewPassword = !_obscureNewPassword);
            },
            isVerySmallScreen: isVerySmallScreen,
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 12),

          // Confirmar senha
          _buildPasswordField(
            label: 'Confirmar Nova Senha',
            controller: _confirmPasswordController,
            isPasswordVisible: !_obscureConfirmPassword,
            onToggleVisibility: () {
              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
            },
            isVerySmallScreen: isVerySmallScreen,
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 20),

          // Botões
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  text: 'CANCELAR',
                  onPressed: () {
                    setState(() {
                      _changingPassword = false;
                      _currentPasswordController.clear();
                      _newPasswordController.clear();
                      _confirmPasswordController.clear();
                    });
                  },
                  gradient: const LinearGradient(
                    colors: [Colors.grey, Colors.grey],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  fullWidth: true,
                  type: null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  text: _isSaving ? 'ALTERANDO...' : 'ALTERAR',
                  onPressed: _isSaving ? null : _changePassword,
                  gradient: AppGradients.mety,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  fullWidth: true,
                  type: null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isVerySmallScreen,
    required bool isSmallScreen,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isVerySmallScreen ? 11 : 12,
            color: AppColors.white.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.metyBlue.withOpacity(0.3),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              color: AppColors.white,
              fontSize: isVerySmallScreen ? 14 : 15,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: AppColors.metyBlue,
                size: isVerySmallScreen ? 18 : 20,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isVerySmallScreen ? 12 : 16,
                vertical: isVerySmallScreen ? 10 : 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField({
    required String label,
    required TextEditingController controller,
    required bool isVerySmallScreen,
    required bool isSmallScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isVerySmallScreen ? 11 : 12,
            color: AppColors.white.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.metyBlue.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: isVerySmallScreen ? 12 : 16),
                child: Icon(
                  Icons.phone_rounded,
                  color: AppColors.metyBlue,
                  size: isVerySmallScreen ? 18 : 20,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: isVerySmallScreen ? 6 : 8),
                child: Text(
                  '+244',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.7),
                    fontSize: isVerySmallScreen ? 14 : 15,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: isVerySmallScreen ? 14 : 15,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isPasswordVisible,
    required VoidCallback onToggleVisibility,
    required bool isVerySmallScreen,
    required bool isSmallScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isVerySmallScreen ? 11 : 12,
            color: AppColors.white.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.metyBlue.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: isVerySmallScreen ? 12 : 16),
                child: Icon(
                  Icons.lock_rounded,
                  color: AppColors.metyBlue,
                  size: isVerySmallScreen ? 18 : 20,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: !isPasswordVisible,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: isVerySmallScreen ? 14 : 15,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.metyBlue,
                ),
                onPressed: onToggleVisibility,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods(bool isVerySmallScreen, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MÉTODOS DE PAGAMENTO',
          style: TextStyle(
            fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14),
            color: AppColors.white.withOpacity(0.6),
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        ..._savedPaymentMethods.map((method) {
          return Padding(
            padding: EdgeInsets.only(bottom: isVerySmallScreen ? 10 : 12),
            child: GlassCard(
              padding: EdgeInsets.all(isVerySmallScreen ? 12 : 14),
              borderRadius: 15,
              child: Row(
                children: [
                  Container(
                    width: isVerySmallScreen ? 36 : 40,
                    height: isVerySmallScreen ? 36 : 40,
                    decoration: BoxDecoration(
                      color: method['color'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: method['color'].withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        method['icon'],
                        color: method['color'],
                        size: isVerySmallScreen ? 18 : 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method['type'],
                          style: TextStyle(
                            fontSize: isVerySmallScreen ? 13 : 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          method['lastFour'],
                          style: TextStyle(
                            fontSize: isVerySmallScreen ? 11 : 12,
                            color: AppColors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.delete_rounded,
                    color: AppColors.metyOrange,
                    size: isVerySmallScreen ? 18 : 20,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        GestureDetector(
          onTap: () {},
          child: GlassCard(
            padding: EdgeInsets.all(isVerySmallScreen ? 12 : 14),
            borderRadius: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_rounded,
                  color: AppColors.metyBlue,
                  size: isVerySmallScreen ? 18 : 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'ADICIONAR MÉTODO',
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 12 : 13,
                    color: AppColors.metyBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTravelPreferences(bool isVerySmallScreen, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PREFERÊNCIAS DE VIAGEM',
          style: TextStyle(
            fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14),
            color: AppColors.white.withOpacity(0.6),
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: EdgeInsets.all(isVerySmallScreen ? 16 : 18),
          borderRadius: 15,
          child: Column(
            children: _travelPreferences.map((pref) {
              return Padding(
                padding: EdgeInsets.only(bottom: isVerySmallScreen ? 12 : 14),
                child: Row(
                  children: [
                    Container(
                      width: isVerySmallScreen ? 36 : 40,
                      height: isVerySmallScreen ? 36 : 40,
                      decoration: BoxDecoration(
                        color: pref['color'].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: pref['color'].withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          pref['icon'],
                          color: pref['color'],
                          size: isVerySmallScreen ? 18 : 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        pref['title'],
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 13 : 14,
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isVerySmallScreen ? 8 : 10,
                        vertical: isVerySmallScreen ? 4 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: pref['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: pref['color'].withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        pref['value'],
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 12 : 13,
                          color: pref['color'],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettings(bool isVerySmallScreen, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONFIGURAÇÕES',
          style: TextStyle(
            fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14),
            color: AppColors.white.withOpacity(0.6),
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: EdgeInsets.all(isVerySmallScreen ? 16 : 18),
          borderRadius: 15,
          child: Column(
            children: _settingsOptions.map((setting) {
              return Padding(
                padding: EdgeInsets.only(bottom: isVerySmallScreen ? 12 : 14),
                child: Row(
                  children: [
                    Container(
                      width: isVerySmallScreen ? 36 : 40,
                      height: isVerySmallScreen ? 36 : 40,
                      decoration: BoxDecoration(
                        color: setting['color'].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: setting['color'].withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          setting['icon'],
                          color: setting['color'],
                          size: isVerySmallScreen ? 18 : 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        setting['title'],
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 13 : 14,
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                    if (setting.containsKey('enabled'))
                      Switch(
                        value: setting['enabled'],
                        onChanged: (value) {
                          setState(() {
                            setting['enabled'] = value;
                          });
                        },
                        activeColor: AppColors.metyBlue,
                        activeTrackColor: AppColors.metyBlue.withOpacity(0.3),
                      )
                    else if (setting.containsKey('value'))
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isVerySmallScreen ? 8 : 10,
                          vertical: isVerySmallScreen ? 4 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: setting['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: setting['color'].withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          setting['value'],
                          style: TextStyle(
                            fontSize: isVerySmallScreen ? 12 : 13,
                            color: setting['color'],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.metyBlue,
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSupport(bool isVerySmallScreen, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SUPORTE & AJUDA',
          style: TextStyle(
            fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14),
            color: AppColors.white.withOpacity(0.6),
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: EdgeInsets.all(isVerySmallScreen ? 16 : 18),
          borderRadius: 15,
          child: Column(
            children: _supportOptions.map((support) {
              return Padding(
                padding: EdgeInsets.only(bottom: isVerySmallScreen ? 12 : 14),
                child: Row(
                  children: [
                    Container(
                      width: isVerySmallScreen ? 36 : 40,
                      height: isVerySmallScreen ? 36 : 40,
                      decoration: BoxDecoration(
                        color: support['color'].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: support['color'].withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          support['icon'],
                          color: support['color'],
                          size: isVerySmallScreen ? 18 : 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        support['title'],
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 13 : 14,
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.metyBlue,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
