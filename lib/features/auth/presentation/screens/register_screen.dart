import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metty_pro/core/theme/app_colors.dart';
import 'package:metty_pro/core/theme/app_gradients.dart';
import 'package:metty_pro/features/auth/passenger/presentation/widgets/glass_card.dart';
import 'package:metty_pro/features/passenger/widgets/gradient_button.dart';
import 'package:metty_pro/core/api/api_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _selectedMunicipality = 'Saurimo';
  final List<String> _municipalities = ['Saurimo', 'Cassengo', 'Muangueji'];

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;
  bool _showPasswordStrength = false;

  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goBackToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidAngolanPhone(String phone) {
    final cleanedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanedPhone.length == 9 && cleanedPhone.startsWith('9');
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  // ===== CORRIGIDO: Nunca retorna 0 =====
  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    
    int strength = 1; // Começa com 1 (muito fraca) para evitar índice -1
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    return strength.clamp(1, 5); // Garantir entre 1-5
  }

  void _validateEmail(String email) {
    if (email.isEmpty) {
      setState(() => _emailError = null);
    } else if (!_isValidEmail(email)) {
      setState(() => _emailError = 'Email inválido');
    } else {
      setState(() => _emailError = null);
    }
  }

  void _validatePhone(String phone) {
    if (phone.isEmpty) {
      setState(() => _phoneError = null);
    } else if (!_isValidAngolanPhone(phone)) {
      setState(() => _phoneError = 'Telefone inválido (9 dígitos, começa com 9)');
    } else {
      setState(() => _phoneError = null);
    }
  }

  void _validatePassword(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordError = null;
        _showPasswordStrength = false;
      });
    } else if (!_isValidPassword(password)) {
      setState(() {
        _passwordError = 'Mínimo 6 caracteres';
        _showPasswordStrength = true;
      });
    } else {
      setState(() {
        _passwordError = null;
        _showPasswordStrength = true;
      });
    }
  }

  void _validateConfirmPassword(String confirmPassword) {
    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = null);
    } else if (confirmPassword != _passwordController.text) {
      setState(() => _confirmPasswordError = 'As senhas não coincidem');
    } else {
      setState(() => _confirmPasswordError = null);
    }
  }

  void _loginWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento'), backgroundColor: AppColors.metyBlue),
    );
  }

  void _loginWithApple() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento'), backgroundColor: AppColors.metyBlue),
    );
  }

  // ===== CORRIGIDO: last_name nunca fica em branco =====
  void _handleRegister() async {
    if (_fullNameController.text.isEmpty) {
      _showErrorSnackbar('Por favor, insira seu nome completo');
      return;
    }
    if (_emailController.text.isEmpty || _emailError != null) {
      _showErrorSnackbar('Por favor, insira um email válido');
      return;
    }
    if (_phoneController.text.isEmpty || _phoneError != null) {
      _showErrorSnackbar('Por favor, insira um telefone válido');
      return;
    }
    if (_passwordController.text.isEmpty || _passwordError != null) {
      _showErrorSnackbar('Por favor, insira uma senha válida');
      return;
    }
    if (_confirmPasswordController.text.isEmpty || _confirmPasswordError != null) {
      _showErrorSnackbar('Por favor, confirme sua senha');
      return;
    }
    if (!_acceptTerms) {
      _showErrorSnackbar('Você precisa aceitar os termos e condições');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ===== CORREÇÃO PRINCIPAL: Garantir que last_name nunca seja vazio =====
      final fullName = _fullNameController.text.trim();
      final nameParts = fullName.split(' ');
      
      String firstName;
      String lastName;
      
      if (nameParts.length == 1) {
        // Apenas um nome: usa o mesmo nome como last_name
        firstName = nameParts[0];
        lastName = nameParts[0]; // Usa o mesmo nome para evitar erro "em branco"
      } else {
        // Nome completo: primeiro nome e resto como sobrenome
        firstName = nameParts.first;
        lastName = nameParts.sublist(1).join(' ');
      }
      
      // Garantir que ambos tenham pelo menos 2 caracteres
      if (firstName.length < 2) firstName = '$firstName.';
      if (lastName.length < 2) lastName = '$lastName.';

      String cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      if (!cleanPhone.startsWith('+244')) {
        cleanPhone = '+244$cleanPhone';
      }

      final userData = {
        'phone': cleanPhone,
        'email': _emailController.text.trim(),
        'first_name': firstName,
        'last_name': lastName, // AGORA NUNCA É VAZIO
        'password': _passwordController.text,
        'password2': _confirmPasswordController.text,
        'user_type': 'PASSENGER',
        'municipality': _selectedMunicipality,
      };

      print('📦 Dados de registro: $userData');
      await ApiClient.register(userData);

      if (mounted) {
        _showSuccessSnackbar('Registro realizado com sucesso! Faça login.');
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        // Traduzir erros comuns do backend
        if (errorMsg.contains('last_name')) {
          errorMsg = 'Erro no nome: informe nome e sobrenome';
        } else if (errorMsg.contains('phone')) {
          errorMsg = 'Este telefone já está cadastrado';
        } else if (errorMsg.contains('email')) {
          errorMsg = 'Este email já está cadastrado';
        }
        _showErrorSnackbar(errorMsg);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
    );
  }

  // ===== CAMPO SENHA (SEM BUG) =====
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool isPasswordVisible,
    required VoidCallback onTogglePassword,
    required bool isSmallScreen,
    String? errorText,
    ValueChanged<String>? onChanged,
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
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: errorText != null ? AppColors.error.withOpacity(0.5) : AppColors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                Icons.lock_rounded,
                color: errorText != null ? AppColors.error : AppColors.metyBlue.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: !isPasswordVisible,
                  enableIMEPersonalizedLearning: false,
                  style: const TextStyle(color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(color: AppColors.white),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    errorText: errorText,
                    errorStyle: const TextStyle(fontSize: 11, color: AppColors.error),
                  ),
                  cursorColor: AppColors.metyBlue,
                  onChanged: onChanged,
                ),
              ),
              GestureDetector(
                onTap: onTogglePassword,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    color: AppColors.metyBlue.withOpacity(0.7),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required bool isSmallScreen,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    ValueChanged<String>? onChanged,
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
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: errorText != null ? AppColors.error.withOpacity(0.5) : AppColors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                icon,
                color: errorText != null ? AppColors.error : AppColors.metyBlue.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: const TextStyle(color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(color: AppColors.white),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    errorText: errorText,
                    errorStyle: const TextStyle(fontSize: 11, color: AppColors.error),
                  ),
                  cursorColor: AppColors.metyBlue,
                  onChanged: onChanged,
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
    String? errorText,
    ValueChanged<String>? onChanged,
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
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: errorText != null ? AppColors.error.withOpacity(0.5) : AppColors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                Icons.phone_rounded,
                color: errorText != null ? AppColors.error : AppColors.metyBlue.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(prefixText, style: const TextStyle(color: AppColors.white)),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  maxLength: 9,
                  style: const TextStyle(color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(color: AppColors.white),
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    errorText: errorText,
                    errorStyle: const TextStyle(fontSize: 11, color: AppColors.error),
                  ),
                  cursorColor: AppColors.metyBlue,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===== CORRIGIDO: Proteção contra índice -1 =====
  Widget _buildPasswordStrength(String password) {
    if (password.isEmpty) return const SizedBox.shrink();
    
    final strength = _calculatePasswordStrength(password);
    final safeStrength = strength.clamp(1, 5); // Garantir mínimo 1
    
    final colors = [AppColors.error, Colors.orange, Colors.yellow, AppColors.success, AppColors.metyBlue];
    final labels = ['Muito fraca', 'Fraca', 'Média', 'Forte', 'Muito forte'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 4 ? 4 : 0),
                decoration: BoxDecoration(
                  color: index < safeStrength ? colors[safeStrength - 1] : AppColors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          labels[safeStrength - 1], 
          style: TextStyle(
            fontSize: 10, 
            color: colors[safeStrength - 1], 
            fontWeight: FontWeight.w600
          ),
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
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 25, vertical: isSmallScreen ? 12 : 15),
        borderRadius: 15,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Scaffold(
      backgroundColor: AppColors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Row(
                children: [
                  GestureDetector(
                    onTap: _goBackToLogin,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: AppColors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => AppGradients.premium.createShader(bounds),
                    child: const Text(
                      'METY',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Confiança em cada corrida',
                    style: TextStyle(fontSize: 14, color: AppColors.white.withOpacity(0.7)),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              GlassCard(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                borderRadius: 25,
                child: Column(
                  children: [
                    Text(
                      'CRIAR CONTA',
                      style: TextStyle(fontSize: isSmallScreen ? 20 : 24, fontWeight: FontWeight.w800, color: AppColors.white),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Junte-se ao METY Pro',
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: AppColors.white.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      controller: _fullNameController,
                      label: 'NOME COMPLETO',
                      hintText: 'João da Silva',
                      icon: Icons.person_rounded,
                      isSmallScreen: isSmallScreen,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _emailController,
                      label: 'EMAIL',
                      hintText: 'seu@email.com',
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      isSmallScreen: isSmallScreen,
                      errorText: _emailError,
                      onChanged: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    _buildPhoneField(
                      controller: _phoneController,
                      label: 'TELEFONE',
                      hintText: '9XX XXX XXX',
                      prefixText: '+244 ',
                      isSmallScreen: isSmallScreen,
                      errorText: _phoneError,
                      onChanged: _validatePhone,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MUNICÍPIO',
                          style: TextStyle(fontSize: isSmallScreen ? 11 : 12, color: AppColors.white.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: AppColors.white.withOpacity(0.1)),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedMunicipality,
                            dropdownColor: AppColors.black,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.location_city_rounded, color: AppColors.metyBlue),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            items: _municipalities.map((String municipality) {
                              return DropdownMenuItem<String>(
                                value: municipality,
                                child: Text(municipality),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) setState(() => _selectedMunicipality = newValue);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _passwordController,
                      label: 'SENHA',
                      hintText: 'Digite sua senha',
                      isPasswordVisible: _isPasswordVisible,
                      onTogglePassword: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      isSmallScreen: isSmallScreen,
                      errorText: _passwordError,
                      onChanged: _validatePassword,
                    ),
                    if (_showPasswordStrength && _passwordController.text.isNotEmpty && _calculatePasswordStrength(_passwordController.text) > 0) ...[
                      const SizedBox(height: 8),
                      _buildPasswordStrength(_passwordController.text),
                    ],
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'CONFIRMAR SENHA',
                      hintText: 'Confirme sua senha',
                      isPasswordVisible: _isConfirmPasswordVisible,
                      onTogglePassword: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                      isSmallScreen: isSmallScreen,
                      errorText: _confirmPasswordError,
                      onChanged: _validateConfirmPassword,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                          child: Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: _acceptTerms ? AppColors.metyBlue : Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: _acceptTerms ? AppColors.metyBlue : AppColors.white.withOpacity(0.3), width: 2),
                            ),
                            child: _acceptTerms ? const Icon(Icons.check_rounded, size: 14, color: AppColors.white) : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: isSmallScreen ? 11 : 12, color: AppColors.white.withOpacity(0.7)),
                              children: [
                                const TextSpan(text: 'Eu concordo com os '),
                                TextSpan(
                                  text: 'Termos de Uso',
                                  style: const TextStyle(color: AppColors.metyBlueLight, decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()..onTap = () {},
                                ),
                                const TextSpan(text: ' e '),
                                TextSpan(
                                  text: 'Política de Privacidade',
                                  style: const TextStyle(color: AppColors.metyBlueLight, decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()..onTap = () {},
                                ),
                                const TextSpan(text: ' do METY Pro'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    GradientButton(
                      text: _isLoading ? 'CRIANDO CONTA...' : 'CRIAR CONTA',
                      onPressed: _isLoading ? null : _handleRegister,
                      gradient: AppGradients.mety,
                      icon: _isLoading ? null : Icons.person_add_rounded,
                      isLoading: _isLoading,
                      fullWidth: true,
                      type: null,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: Container(height: 1, color: AppColors.white.withOpacity(0.1))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text('ou registre-se com', style: TextStyle(fontSize: isSmallScreen ? 10 : 12, color: AppColors.white.withOpacity(0.5))),
                        ),
                        Expanded(child: Container(height: 1, color: AppColors.white.withOpacity(0.1))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          icon: Icons.g_mobiledata_rounded,
                          label: 'Google',
                          onPressed: _loginWithGoogle,
                          color: AppColors.error,
                          isSmallScreen: isSmallScreen,
                        ),
                        const SizedBox(width: 15),
                        _buildSocialButton(
                          icon: Icons.apple,
                          label: 'Apple',
                          onPressed: _loginWithApple,
                          color: AppColors.white,
                          isSmallScreen: isSmallScreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text('Já tem uma conta? ', style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: AppColors.white.withOpacity(0.6))),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: Text(
                            'Faça login',
                            style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: AppColors.metyBlueLight, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    Text('DESENVOLVIDO POR', style: TextStyle(fontSize: 10, color: AppColors.white.withOpacity(0.4), letterSpacing: 3)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.metyBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.metyBlue.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.developer_board_rounded, color: AppColors.metyBlue, size: 14),
                          SizedBox(width: 6),
                          Text('MBSoft Benvindo Mersh', style: TextStyle(fontSize: 12, color: AppColors.metyBlue, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('© 2026 METY Pro - Todos os direitos reservados', style: TextStyle(fontSize: 9, color: AppColors.white.withOpacity(0.3))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}