import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:best_flutter_ui_templates/auth/AuthService.dart';
import 'package:best_flutter_ui_templates/utils/logger.dart';
import 'package:best_flutter_ui_templates/navigation_home_screen.dart';

/// LoginScreen - Màn hình đăng nhập phong cách iOS 26 (Liquid Glass)
/// Tính năng:
/// - Nhập tài khoản + mật khẩu
/// - Lưu thông tin vào bộ nhớ an toàn (FlutterSecureStorage)
/// - Xác thực sinh trắc học (vân tay/khuôn mặt)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService.instance;

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _canUseBiometrics = false;
  bool _hasSavedCredentials = false;
  bool _biometricEnabled = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controllers
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();

    _initAuth();
  }

  Future<void> _initAuth() async {
    final canBio = await _authService.canUseBiometrics();
    final isLoggedIn = await _authService.isLoggedIn();
    final bioEnabled = await _authService.isBiometricEnabled();
    final savedUsername = await _authService.getSavedUsername();

    setState(() {
      _canUseBiometrics = canBio;
      _hasSavedCredentials = isLoggedIn;
      _biometricEnabled = bioEnabled;
      if (savedUsername != null) {
        _usernameController.text = savedUsername;
      }
    });

    // Tự động hiển thị xác thực sinh trắc nếu đã bật và đã đăng nhập trước đó
    // if (_canUseBiometrics && _hasSavedCredentials && _biometricEnabled) {
    //   await Future.delayed(const Duration(milliseconds: 600));
    //   _loginWithBiometrics();
    // }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // ==================== XỬ LÝ ĐĂNG NHẬP ====================

  Future<void> _loginWithCredentials() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Giả lập gọi API đăng nhập (thay bằng API thực tế)
      await Future.delayed(const Duration(seconds: 1));

      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      // Lưu thông tin vào bộ nhớ an toàn
      await _authService.saveCredentials(
        username: username,
        password: password,
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Nếu thiết bị hỗ trợ sinh trắc, hỏi người dùng bật
      if (_canUseBiometrics && !_biometricEnabled) {
        await _askEnableBiometrics();
      }

      _showLoginSuccess(username);
    } catch (e) {
      logger.e('Đăng nhập thất bại: $e');
      _showError('Đăng nhập thất bại. Vui lòng thử lại.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithBiometrics() async {
    setState(() => _isLoading = true);

    try {
      final credentials = await _authService.getCredentialsSecurely();

      if (credentials != null && credentials['username'] != null) {
        _showLoginSuccess(credentials['username']!);
      } else {
        _showError('Xác thực thất bại hoặc không có dữ liệu đăng nhập.');
      }
    } catch (e) {
      logger.e('Xác thực sinh trắc thất bại: $e');
      _showError('Xác thực sinh trắc thất bại.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _askEnableBiometrics() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.fingerprint, color: Color(0xFF007AFF), size: 28),
            SizedBox(width: 12),
            Text('Sinh trắc học'),
          ],
        ),
        content: const Text(
          'Bạn có muốn bật đăng nhập bằng vân tay/khuôn mặt cho lần sau không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Bật'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _authService.setBiometricEnabled(true);
      setState(() => _biometricEnabled = true);
    }
  }

  void _showLoginSuccess(String username) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 56),
        title: const Text('Đăng nhập thành công!'),
        content: Text('Chào mừng, $username'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const NavigationHomeScreen(),
                ),
              );
            },
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ==================== BUILD UI ====================

  @override
  Widget build(BuildContext context) {
    // Thiết lập StatusBar trong suốt cho hiệu ứng immersive
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient iOS 26
          _buildBackground(),

          // Nội dung chính
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildContent(),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E), // Deep navy
            Color(0xFF16213E), // Dark blue
            Color(0xFF0F3460), // Medium blue
            Color(0xFF1A1A2E), // Back to navy
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Hiệu ứng ánh sáng mờ phía trên (Liquid Glass feel)
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF007AFF).withOpacity(0.25),
                    const Color(0xFF007AFF).withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF5856D6).withOpacity(0.18),
                    const Color(0xFF5856D6).withOpacity(0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Thêm một điểm sáng nhỏ ở giữa-phải
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF30D158).withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 60),

          // Logo / Icon
          _buildLogo(),

          const SizedBox(height: 40),

          // Glass Card chứa form đăng nhập
          _buildGlassCard(),

          const SizedBox(height: 24),

          // Nút xác thực sinh trắc học
          if (_canUseBiometrics && _hasSavedCredentials && _biometricEnabled)
            _buildBiometricButton(),

          const SizedBox(height: 32),

          // Footer
          _buildFooter(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Icon app
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007AFF).withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),

        // Tiêu đề
        const Text(
          'Chào mừng trở lại',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Đăng nhập để tiếp tục',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Username field
                _buildTextField(
                  controller: _usernameController,
                  label: 'Tài khoản',
                  icon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tài khoản';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password field
                _buildTextField(
                  controller: _passwordController,
                  label: 'Mật khẩu',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 4) {
                      return 'Mật khẩu phải từ 4 ký tự trở lên';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Quên mật khẩu
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Tính năng đang phát triển'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                    child: Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                        color: const Color(0xFF007AFF).withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Nút đăng nhập
                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !_isPasswordVisible,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 15,
        ),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5), size: 22),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white.withOpacity(0.5),
                  size: 22,
                ),
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF007AFF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007AFF).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _loginWithCredentials,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Đăng nhập',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return Column(
      children: [
        // Divider với text
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'hoặc',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
          ],
        ),

        const SizedBox(height: 24),

        // Nút sinh trắc học dạng glass
        GestureDetector(
          onTap: _isLoading ? null : _loginWithBiometrics,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 32,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.06),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fingerprint_rounded,
                      color: const Color(0xFF007AFF).withOpacity(0.9),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Đăng nhập bằng sinh trắc học',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        if (_hasSavedCredentials)
          TextButton(
            onPressed: () async {
              await _authService.logout();
              setState(() {
                _hasSavedCredentials = false;
                _usernameController.clear();
                _passwordController.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã xoá thông tin đăng nhập'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Text(
              'Xoá thông tin đã lưu',
              style: TextStyle(
                color: const Color(0xFFFF3B30).withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),

        const SizedBox(height: 8),
        Text(
          'Phiên bản 1.0.0',
          style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.1),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF007AFF),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Đang xác thực...',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
