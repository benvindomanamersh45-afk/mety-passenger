import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metty_pro/core/theme/app_colors.dart';
import 'package:metty_pro/core/theme/app_gradients.dart';
import 'package:metty_pro/features/auth/passenger/presentation/widgets/glass_card.dart';
import 'package:metty_pro/features/passenger/widgets/gradient_button.dart';
import 'package:metty_pro/core/api/api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _slideUp;
  late Animation<double> _backgroundOffset;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _recoveryEmailController = TextEditingController();
  final TextEditingController _recoveryPhoneController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _usePhoneLogin = false;
  bool _isForgotPassword = false;
  bool _usePhoneRecovery = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _slideUp = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _backgroundOffset = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _recoveryEmailController.dispose();
    _recoveryPhoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    String identifier;
    if (_usePhoneLogin) {
      if (_phoneController.text.isEmpty) {
        _showErrorSnackbar('Por favor, insira seu telefone');
        return;
      }
      if (!_isValidAngolanPhone(_phoneController.text)) {
        _showErrorSnackbar('Número de telefone inválido');
        return;
      }
      identifier = '+244${_phoneController.text.replaceAll(RegExp(r'[^\d]'), '')}';
    } else {
      if (_emailController.text.isEmpty) {
        _showErrorSnackbar('Por favor, insira seu email');
        return;
      }
      if (!_isValidEmail(_emailController.text)) {
        _showErrorSnackbar('Email inválido');
        return;
      }
      identifier = _emailController.text;
    }

    if (_passwordController.text.isEmpty) {
      _showErrorSnackbar('Por favor, insira sua senha');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiClient.login(identifier, _passwordController.text);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Email/Telefone ou senha incorretos');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    String identifier;
    if (_usePhoneRecovery) {
      if (_recoveryPhoneController.text.isEmpty) {
        _showErrorSnackbar('Por favor, insira seu telefone');
        return;
      }
      if (!_isValidAngolanPhone(_recoveryPhoneController.text)) {
        _showErrorSnackbar('Número de telefone inválido');
        return;
      }
      identifier = '+244${_recoveryPhoneController.text.replaceAll(RegExp(r'[^\d]'), '')}';
    } else {
      if (_recoveryEmailController.text.isEmpty) {
        _showErrorSnackbar('Por favor, insira seu email');
        return;
      }
      if (!_isValidEmail(_recoveryEmailController.text)) {
        _showErrorSnackbar('Email inválido');
        return;
      }
      identifier = _recoveryEmailController.text;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Integrar com a API de recuperação de senha do backend
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        _showSuccessSnackbar(
          'Instruções de recuperação de senha enviadas para ${_usePhoneRecovery ? "seu telefone" : "seu email"}!',
        );
        setState(() => _isForgotPassword = false);
        _recoveryEmailController.clear();
        _recoveryPhoneController.clear();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Erro ao recuperar senha. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loginWithGoogle() {
    _showInfoSnackbar('Funcionalidade em desenvolvimento. Em breve disponível!');
  }

  void _loginWithApple() {
    _showInfoSnackbar('Funcionalidade em desenvolvimento. Em breve disponível!');
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidAngolanPhone(String phone) {
    final cleanedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanedPhone.length == 9 && cleanedPhone.startsWith('9');
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

  void _showInfoSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.metyBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isVerySmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // Fundo animado
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundOffset,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        0.5,
                        -0.3 + _backgroundOffset.value * 0.2,
                      ),
                      radius: 1.2,
                      colors: [
                        AppColors.metyBlue.withOpacity(0.15),
                        AppColors.black,
                      ],
                      stops: const [0.0, 0.7],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: isSmallScreen ? 50 : 70),

                  // Botão voltar
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: isSmallScreen ? 36 : 40,
                          height: isSmallScreen ? 36 : 40,
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
                            size: isSmallScreen ? 18 : 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 30),

                  // Logo e título
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
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return AppGradients.premium.createShader(bounds);
                          },
                          child: const Text(
                            'METY',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6,
                              height: 0.9,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 5 : 8),
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
                  SizedBox(height: isSmallScreen ? 15 : 20),

                  // Card principal (login ou recuperação)
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
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      borderRadius: 25,
                      child: Column(
                        children: [
                          Text(
                            _isForgotPassword ? 'RECUPERAR SENHA' : 'ENTRAR NA CONTA',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 20 : 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 3 : 5),
                          Text(
                            _isForgotPassword
                                ? 'Redefina sua senha'
                                : 'Acesse sua conta premium',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: AppColors.white.withOpacity(0.6),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 25),

                          // Seletor de login (Email/Telefone) ou Recuperação
                          if (!_isForgotPassword) ...[
                            _buildLoginSelector(isSmallScreen),
                            SizedBox(height: isSmallScreen ? 20 : 25),
                          ] else ...[
                            _buildRecoverySelector(isSmallScreen),
                            SizedBox(height: isSmallScreen ? 20 : 25),
                          ],

                          // Campos de entrada
                          if (!_isForgotPassword) ...[
                            if (!_usePhoneLogin)
                              _buildInputField(
                                controller: _emailController,
                                label: 'EMAIL',
                                hintText: 'seu@email.com',
                                prefixIcon: Icons.email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                isSmallScreen: isSmallScreen,
                              )
                            else
                              _buildPhoneField(
                                controller: _phoneController,
                                label: 'TELEFONE',
                                hintText: '9XX XXX XXX',
                                prefixText: '+244 ',
                                isSmallScreen: isSmallScreen,
                              ),
                            SizedBox(height: isSmallScreen ? 16 : 20),
                            _buildPasswordField(
                              controller: _passwordController,
                              label: 'SENHA',
                              hintText: '••••••••',
                              isPasswordVisible: _isPasswordVisible,
                              onTogglePassword: () =>
                                  setState(() => _isPasswordVisible = !_isPasswordVisible),
                              isSmallScreen: isSmallScreen,
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildRememberMeCheckbox(isSmallScreen),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _isForgotPassword = true),
                                  child: Text(
                                    'Esqueci a senha?',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 12 : 14,
                                      color: AppColors.metyBlueLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? 25 : 30),
                          ] else ...[
                            if (!_usePhoneRecovery)
                              _buildInputField(
                                controller: _recoveryEmailController,
                                label: 'EMAIL',
                                hintText: 'seu@email.com',
                                prefixIcon: Icons.email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                isSmallScreen: isSmallScreen,
                              )
                            else
                              _buildPhoneField(
                                controller: _recoveryPhoneController,
                                label: 'TELEFONE',
                                hintText: '9XX XXX XXX',
                                prefixText: '+244 ',
                                isSmallScreen: isSmallScreen,
                              ),
                            SizedBox(height: isSmallScreen ? 16 : 20),
                            // CORRIGIDO: textAlign no widget Text, não no TextStyle
                            Text(
                              'Digite seu ${_usePhoneRecovery ? "telefone" : "email"} para receber as instruções de recuperação',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 13,
                                color: AppColors.white.withOpacity(0.6),
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 25 : 30),
                          ],

                          // Botão principal
                          GradientButton(
                            text: _isLoading
                                ? (_isForgotPassword ? 'ENVIANDO...' : 'ENTRANDO...')
                                : (_isForgotPassword ? 'ENVIAR RECUPERAÇÃO' : 'ENTRAR'),
                            onPressed: _isLoading
                                ? null
                                : (_isForgotPassword
                                    ? _handleForgotPassword
                                    : _handleLogin),
                            gradient: AppGradients.mety,
                            icon: _isLoading
                                ? null
                                : (_isForgotPassword
                                    ? Icons.send_rounded
                                    : Icons.arrow_forward_rounded),
                            isLoading: _isLoading,
                            fullWidth: true,
                            type: null,
                          ),
                          if (_isForgotPassword) ...[
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isForgotPassword = false;
                                  _recoveryEmailController.clear();
                                  _recoveryPhoneController.clear();
                                });
                              },
                              child: Text(
                                'Voltar para o login',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  color: AppColors.metyBlueLight,
                                ),
                              ),
                            ),
                          ] else ...[
                            SizedBox(height: isSmallScreen ? 20 : 24),
                            _buildSocialDivider(isSmallScreen),
                            SizedBox(height: isSmallScreen ? 20 : 24),
                            _buildSocialButtons(isSmallScreen),
                            SizedBox(height: isSmallScreen ? 20 : 24),
                            _buildRegisterLink(isSmallScreen),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 30 : 40),
                  _buildFooter(isVerySmallScreen, isSmallScreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MÉTODOS AUXILIARES DE UI ====================

  Widget _buildLoginSelector(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _usePhoneLogin = false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  color: !_usePhoneLogin
                      ? AppColors.metyBlue.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'EMAIL',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: !_usePhoneLogin
                          ? AppColors.metyBlue
                          : AppColors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _usePhoneLogin = true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  color: _usePhoneLogin
                      ? AppColors.metyBlue.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'TELEFONE',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: _usePhoneLogin
                          ? AppColors.metyBlue
                          : AppColors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoverySelector(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _usePhoneRecovery = false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  color: !_usePhoneRecovery
                      ? AppColors.metyBlue.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'EMAIL',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: !_usePhoneRecovery
                          ? AppColors.metyBlue
                          : AppColors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _usePhoneRecovery = true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  color: _usePhoneRecovery
                      ? AppColors.metyBlue.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'TELEFONE',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: _usePhoneRecovery
                          ? AppColors.metyBlue
                          : AppColors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    required bool isSmallScreen,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 11 : 12,
            color: AppColors.white.withOpacity(0.7),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.white.withOpacity(0.05),
                AppColors.white.withOpacity(0.02),
              ],
            ),
            border: Border.all(
              color: AppColors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: isSmallScreen ? 12 : 16),
                child: Icon(
                  prefixIcon,
                  color: AppColors.metyBlue.withOpacity(0.7),
                  size: isSmallScreen ? 18 : 20,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: AppColors.white.withOpacity(0.3),
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 16 : 18,
                    ),
                  ),
                  cursorColor: AppColors.metyBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String prefixText,
    required bool isSmallScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 11 : 12,
            color: AppColors.white.withOpacity(0.7),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.white.withOpacity(0.05),
                AppColors.white.withOpacity(0.02),
              ],
            ),
            border: Border.all(
              color: AppColors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: isSmallScreen ? 12 : 16),
                child: Icon(
                  Icons.phone_rounded,
                  color: AppColors.metyBlue.withOpacity(0.7),
                  size: isSmallScreen ? 18 : 20,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: isSmallScreen ? 6 : 8),
                child: Text(
                  prefixText,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.7),
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  maxLength: 9,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: AppColors.white.withOpacity(0.3),
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: isSmallScreen ? 16 : 18,
                    ),
                  ),
                  cursorColor: AppColors.metyBlue,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool isPasswordVisible,
    required VoidCallback onTogglePassword,
    required bool isSmallScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 11 : 12,
            color: AppColors.white.withOpacity(0.7),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.white.withOpacity(0.05),
                AppColors.white.withOpacity(0.02),
              ],
            ),
            border: Border.all(
              color: AppColors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: isSmallScreen ? 12 : 16),
                child: Icon(
                  Icons.lock_rounded,
                  color: AppColors.metyBlue.withOpacity(0.7),
                  size: isSmallScreen ? 18 : 20,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: !isPasswordVisible,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: AppColors.white.withOpacity(0.3),
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 16 : 18,
                    ),
                  ),
                  cursorColor: AppColors.metyBlue,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: isSmallScreen ? 12 : 16),
                child: GestureDetector(
                  onTap: onTogglePassword,
                  child: Icon(
                    isPasswordVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: AppColors.metyBlue.withOpacity(0.7),
                    size: isSmallScreen ? 18 : 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMeCheckbox(bool isSmallScreen) {
    return GestureDetector(
      onTap: () => setState(() => _rememberMe = !_rememberMe),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 18 : 20,
            height: isSmallScreen ? 18 : 20,
            decoration: BoxDecoration(
              color: _rememberMe ? AppColors.metyBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: _rememberMe
                    ? AppColors.metyBlue
                    : AppColors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: _rememberMe
                ? Icon(
                    Icons.check_rounded,
                    size: isSmallScreen ? 12 : 14,
                    color: AppColors.white,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            'Lembrar de mim',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: AppColors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialDivider(bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: AppColors.white.withOpacity(0.1)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'ou continue com',
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              color: AppColors.white.withOpacity(0.5),
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: AppColors.white.withOpacity(0.1)),
        ),
      ],
    );
  }

  Widget _buildSocialButtons(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: Icons.g_mobiledata_rounded,
          label: 'Google',
          onPressed: _loginWithGoogle,
          color: AppColors.error,
          isSmallScreen: isSmallScreen,
        ),
        SizedBox(width: isSmallScreen ? 15 : 20),
        _buildSocialButton(
          icon: Icons.apple,
          label: 'Apple',
          onPressed: _loginWithApple,
          color: AppColors.white,
          isSmallScreen: isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: GlassCard(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 20 : 25,
          vertical: isSmallScreen ? 12 : 15,
        ),
        borderRadius: 15,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: isSmallScreen ? 18 : 20),
            SizedBox(width: isSmallScreen ? 8 : 10),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink(bool isSmallScreen) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Text(
          'Não tem uma conta? ',
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            color: AppColors.white.withOpacity(0.6),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/register'),
          child: Text(
            'Registre-se agora',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: AppColors.metyBlueLight,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isVerySmallScreen, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(bottom: isVerySmallScreen ? 30 : 40),
      child: Column(
        children: [
          Text(
            'DESENVOLVIDO POR',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.white.withOpacity(0.4),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.metyBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.metyBlue.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.developer_board_rounded,
                  color: AppColors.metyBlue,
                  size: 14,
                ),
                const SizedBox(width: 6),
                const Text(
                  'MBSoft Benvindo Mersh',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.metyBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '© 2025 METY Pro - Todos os direitos reservados',
            style: TextStyle(
              fontSize: 9,
              color: AppColors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}