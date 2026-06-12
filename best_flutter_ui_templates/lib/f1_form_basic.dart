import 'package:flutter/material.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'utils/logger.dart';

// ─────────────────────────────────────────────────────────────
// Model: Stores all registration information after successful submission
// ─────────────────────────────────────────────────────────────
class RegistrationData {
  final String fullName;
  final String phone;
  final String email;
  final String password;
  final String province;
  final Gender gender;
  final bool agreedToTerms;

  const RegistrationData({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.password,
    required this.province,
    required this.gender,
    required this.agreedToTerms,
  });

  @override
  String toString() {
    return 'RegistrationData('
        'fullName: $fullName, '
        'phone: $phone, '
        'email: $email, '
        'password: ••••••, '
        'province: $province, '
        'gender: ${gender.label}, '
        'agreedToTerms: $agreedToTerms)';
  }
}

enum Gender {
  male('Nam'),
  female('Nữ'),
  other('Khác');

  final String label;
  const Gender(this.label);
}

// ─────────────────────────────────────────────────────────────
// Constants: Province list (63 tỉnh thành, không trùng lặp)
// ─────────────────────────────────────────────────────────────
const List<String> kProvinces = [
  'An Giang',
  'Bà Rịa - Vũng Tàu',
  'Bắc Giang',
  'Bắc Kạn',
  'Bạc Liêu',
  'Bắc Ninh',
  'Bến Tre',
  'Bình Định',
  'Bình Dương',
  'Bình Phước',
  'Bình Thuận',
  'Cà Mau',
  'Cần Thơ',
  'Cao Bằng',
  'Đà Nẵng',
  'Đắk Lắk',
  'Đắk Nông',
  'Điện Biên',
  'Đồng Nai',
  'Đồng Tháp',
  'Gia Lai',
  'Hà Giang',
  'Hà Nam',
  'Hà Nội',
  'Hà Tĩnh',
  'Hải Dương',
  'Hải Phòng',
  'Hậu Giang',
  'Hòa Bình',
  'Hồ Chí Minh',
  'Hưng Yên',
  'Khánh Hòa',
  'Kiên Giang',
  'Kon Tum',
  'Lai Châu',
  'Lâm Đồng',
  'Lạng Sơn',
  'Lào Cai',
  'Long An',
  'Nam Định',
  'Nghệ An',
  'Ninh Bình',
  'Ninh Thuận',
  'Phú Thọ',
  'Phú Yên',
  'Quảng Bình',
  'Quảng Nam',
  'Quảng Ngãi',
  'Quảng Ninh',
  'Quảng Trị',
  'Sóc Trăng',
  'Sơn La',
  'Tây Ninh',
  'Thái Bình',
  'Thái Nguyên',
  'Thanh Hóa',
  'Thừa Thiên Huế',
  'Tiền Giang',
  'Trà Vinh',
  'Tuyên Quang',
  'Vĩnh Long',
  'Vĩnh Phúc',
  'Yên Bái',
];

// ─────────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────────
class FormBasicDemo extends StatefulWidget {
  const FormBasicDemo({super.key});

  @override
  State<FormBasicDemo> createState() => _FormBasicDemoState();
}

class _FormBasicDemoState extends State<FormBasicDemo> {
  // ── Controllers ──────────────────────────────────────────
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ── Focus Nodes ──────────────────────────────────────────
  final _nameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  // ── ValueNotifiers (isolated rebuilds – no setState) ─────
  final _passwordObscureNotifier = ValueNotifier<bool>(true);
  final _confirmPasswordObscureNotifier = ValueNotifier<bool>(true);
  final _genderNotifier = ValueNotifier<Gender?>(null);
  final _agreedToTermsNotifier = ValueNotifier<bool>(false);
  final _agreedToTermsErrorNotifier = ValueNotifier<bool>(false);

  // ── Form key ─────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ── Selected province (managed via DropdownFlutter callback) ──
  String? _selectedProvince;

  // ── Submission result ────────────────────────────────────
  RegistrationData? _registrationData;

  // ─────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────
  @override
  void dispose() {
    // Controllers
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    // Focus nodes
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    // Value notifiers
    _passwordObscureNotifier.dispose();
    _confirmPasswordObscureNotifier.dispose();
    _genderNotifier.dispose();
    _agreedToTermsNotifier.dispose();
    _agreedToTermsErrorNotifier.dispose();

    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  // Validation Methods
  // ─────────────────────────────────────────────────────────
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Họ và tên không được để trống';
    }
    if (value.trim().length < 2) {
      return 'Họ và tên phải có ít nhất 2 ký tự';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Số điện thoại không được để trống';
    }
    final phoneRegex = RegExp(r'^(0|\+84)[0-9]{9}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Số điện thoại không hợp lệ (VD: 0912345678)';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email không được để trống';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Địa chỉ email không hợp lệ (VD: abc@example.com)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải chứa ít nhất 6 ký tự';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ hoa';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ số';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != _passwordController.text) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────
  void _submitForm() {
    // Close keyboard
    FocusScope.of(context).unfocus();

    // Validate non-form fields first
    final gender = _genderNotifier.value;
    final agreedToTerms = _agreedToTermsNotifier.value;

    bool hasExtraErrors = false;

    if (_selectedProvince == null) {
      hasExtraErrors = true;
    }
    if (gender == null) {
      hasExtraErrors = true;
    }
    if (!agreedToTerms) {
      hasExtraErrors = true;
      _agreedToTermsErrorNotifier.value = true;
    } else {
      _agreedToTermsErrorNotifier.value = false;
    }

    final isFormValid = _formKey.currentState!.validate();

    if (!isFormValid || hasExtraErrors) {
      // Show snackbar for non-form errors
      if (hasExtraErrors && isFormValid) {
        String errorMsg = '';
        if (_selectedProvince == null) {
          errorMsg = 'Vui lòng chọn tỉnh/thành phố';
        } else if (gender == null) {
          errorMsg = 'Vui lòng chọn giới tính';
        } else if (!agreedToTerms) {
          errorMsg = 'Vui lòng đồng ý điều khoản sử dụng';
        }
        _showErrorSnackBar(errorMsg);
      }

      // Focus first invalid text field
      if (!isFormValid) {
        if (_validateName(_nameController.text) != null) {
          _nameFocusNode.requestFocus();
        } else if (_validatePhone(_phoneController.text) != null) {
          _phoneFocusNode.requestFocus();
        } else if (_validateEmail(_emailController.text) != null) {
          _emailFocusNode.requestFocus();
        } else if (_validatePassword(_passwordController.text) != null) {
          _passwordFocusNode.requestFocus();
        } else if (_validateConfirmPassword(_confirmPasswordController.text) !=
            null) {
          _confirmPasswordFocusNode.requestFocus();
        }
      }
      return;
    }

    // ✅ All valid – create the registration data object
    final data = RegistrationData(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      province: _selectedProvince!,
      gender: gender!,
      agreedToTerms: agreedToTerms,
    );

    setState(() {
      _registrationData = data;
    });

    logger.e('REGISTRATION DATA SAVED: $data');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text('Đăng ký tài khoản thành công!')),
          ],
        ),
        backgroundColor: Colors.teal.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _resetForm() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _formKey.currentState!.reset();
    _genderNotifier.value = null;
    _agreedToTermsNotifier.value = false;
    _agreedToTermsErrorNotifier.value = false;
    _passwordObscureNotifier.value = true;
    _confirmPasswordObscureNotifier.value = true;
    _selectedProvince = null;
    setState(() {
      _registrationData = null;
    });
    _nameFocusNode.requestFocus();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // UI Helpers
  // ─────────────────────────────────────────────────────────
  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: Colors.indigo.shade400),
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 15),
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
    );
  }

  /// Build a section label (e.g. "Giới tính", "Tỉnh/Thành phố")
  Widget _buildSectionLabel(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.indigo.shade400),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a clear button that appears only when the controller has text.
  /// Uses ListenableBuilder for isolated rebuild.
  Widget _buildClearButton(TextEditingController controller) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.text.isEmpty) return const SizedBox.shrink();
        return IconButton(
          icon: const Icon(Icons.clear, color: Colors.grey),
          onPressed: controller.clear,
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text(
          'Đăng ký tài khoản',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        // right: false,
        // left: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Intro Card ──────────────────────────
              _buildHeaderCard(),
              const SizedBox(height: 10),

              // ── Form Card ─────────────────────────────────
              _buildFormCard(),
              const SizedBox(height: 24),

              // ── Result Card ───────────────────────────────
              _buildResultCard(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Header Card – Dynamic welcome text via ListenableBuilder
  // ─────────────────────────────────────────────────────────
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade700, Colors.indigo.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic welcome text – only this Text rebuilds when name changes
          ListenableBuilder(
            listenable: _nameController,
            builder: (context, _) {
              final displayName = _nameController.text.trim();
              return Text(
                'Chào mừng ${displayName.isEmpty ? 'bạn' : displayName}!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          const Text(
            'Vui lòng điền đầy đủ các thông tin bên dưới để tạo tài khoản mới.',
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.3),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Form Card
  // ─────────────────────────────────────────────────────────
  Widget _buildFormCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Họ và tên ──
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                decoration: _buildInputDecoration(
                  labelText: 'Họ và tên *',
                  hintText: 'Ví dụ: Nguyễn Văn Tuấn',
                  prefixIcon: Icons.person_outline,
                  suffixIcon: _buildClearButton(_nameController),
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 18),

              // ── 2. Số điện thoại ──
              TextFormField(
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                maxLength: 10,
                decoration: _buildInputDecoration(
                  labelText: 'Số điện thoại *',
                  hintText: 'Ví dụ: 0912345678',
                  prefixIcon: Icons.phone_outlined,
                  suffixIcon: _buildClearButton(_phoneController),
                ),
                validator: _validatePhone,
              ),
              const SizedBox(height: 18),

              // ── 3. Email ──
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _buildInputDecoration(
                  labelText: 'Địa chỉ email *',
                  hintText: 'Ví dụ: tuan.nguyen@example.com',
                  prefixIcon: Icons.mail_outline,
                  suffixIcon: _buildClearButton(_emailController),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 18),

              // ── 4. Mật khẩu ──
              ValueListenableBuilder<bool>(
                valueListenable: _passwordObscureNotifier,
                builder: (context, isObscure, _) {
                  return TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: isObscure,
                    textInputAction: TextInputAction.next,
                    decoration: _buildInputDecoration(
                      labelText: 'Mật khẩu *',
                      hintText: 'Ít nhất 6 ký tự, 1 chữ hoa, 1 số',
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () =>
                            _passwordObscureNotifier.value = !isObscure,
                      ),
                    ),
                    validator: _validatePassword,
                  );
                },
              ),
              const SizedBox(height: 18),

              // ── 5. Xác nhận mật khẩu ──
              ValueListenableBuilder<bool>(
                valueListenable: _confirmPasswordObscureNotifier,
                builder: (context, isObscure, _) {
                  return TextFormField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocusNode,
                    obscureText: isObscure,
                    textInputAction: TextInputAction.done,
                    decoration: _buildInputDecoration(
                      labelText: 'Xác nhận mật khẩu *',
                      hintText: 'Nhập lại mật khẩu',
                      prefixIcon: Icons.lock_reset_outlined,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () =>
                            _confirmPasswordObscureNotifier.value = !isObscure,
                      ),
                    ),
                    validator: _validateConfirmPassword,
                  );
                },
              ),
              const SizedBox(height: 24),

              // ── 6. Dropdown chọn Tỉnh/Thành phố (DropdownFlutter) ──
              _buildSectionLabel(
                'Tỉnh / Thành phố *',
                Icons.location_city_outlined,
              ),
              DropdownFlutter<String>.search(
                hintText: 'Chọn tỉnh/thành phố',
                items: kProvinces,
                initialItem: _selectedProvince,
                onChanged: (value) {
                  _selectedProvince = value;
                },
              ),
              const SizedBox(height: 24),

              // ── 7. Radio chọn giới tính ──
              _buildSectionLabel('Giới tính *', Icons.wc_outlined),
              ValueListenableBuilder<Gender?>(
                valueListenable: _genderNotifier,
                builder: (context, selectedGender, _) {
                  return Row(
                    children: Gender.values.map((gender) {
                      final isSelected = selectedGender == gender;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _genderNotifier.value = gender,
                          child: Container(
                            margin: EdgeInsets.only(
                              right: gender != Gender.other ? 8 : 0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.indigo.shade50
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.indigo.shade400
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<Gender>(
                                  value: gender,
                                  groupValue: selectedGender,
                                  onChanged: (val) =>
                                      _genderNotifier.value = val,
                                  activeColor: Colors.indigo,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                                Text(
                                  gender.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.indigo.shade700
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // ── 8. Checkbox đồng ý điều khoản ──
              ValueListenableBuilder<bool>(
                valueListenable: _agreedToTermsErrorNotifier,
                builder: (context, hasError, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: _agreedToTermsNotifier,
                    builder: (context, agreed, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              final newValue = !agreed;
                              _agreedToTermsNotifier.value = newValue;
                              if (newValue) {
                                _agreedToTermsErrorNotifier.value = false;
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: hasError
                                    ? Colors.red.shade50
                                    : (agreed
                                          ? Colors.indigo.shade50
                                          : Colors.grey.shade50),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: hasError
                                      ? Colors.red.shade400
                                      : (agreed
                                            ? Colors.indigo.shade400
                                            : Colors.grey.shade300),
                                  width: (agreed || hasError) ? 2 : 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: agreed,
                                    onChanged: (val) {
                                      final newValue = val ?? false;
                                      _agreedToTermsNotifier.value = newValue;
                                      if (newValue) {
                                        _agreedToTermsErrorNotifier.value =
                                            false;
                                      }
                                    },
                                    activeColor: Colors.indigo,
                                    checkColor: Colors.white,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        text: 'Tôi đồng ý với ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Điều khoản sử dụng',
                                            style: TextStyle(
                                              color: Colors.indigo.shade600,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          const TextSpan(text: ' và '),
                                          TextSpan(
                                            text: 'Chính sách bảo mật',
                                            style: TextStyle(
                                              color: Colors.indigo.shade600,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration.underline,
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
                          if (hasError)
                            Padding(
                              padding: const EdgeInsets.only(left: 12, top: 6),
                              child: Text(
                                'Bạn phải đồng ý với điều khoản sử dụng và chính sách bảo mật',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 30),

              // ── Buttons ──
              Row(
                children: [
                  // Reset
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetForm,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: Colors.grey.shade700,
                      ),
                      child: const Text(
                        'Đặt lại',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Submit
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        shadowColor: Colors.indigo.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Đăng ký',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Result Card – Shows submitted data
  // ─────────────────────────────────────────────────────────
  Widget _buildResultCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _registrationData != null
          ? Card(
              key: const ValueKey('result_card'),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.teal.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.teal.shade200, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.assignment_turned_in,
                          color: Colors.teal.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Thông tin đã đăng ký',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade900,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildResultRow(
                      Icons.person_outline,
                      'Họ và tên',
                      _registrationData!.fullName,
                    ),
                    const SizedBox(height: 12),
                    _buildResultRow(
                      Icons.phone_outlined,
                      'Số điện thoại',
                      _registrationData!.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildResultRow(
                      Icons.mail_outline,
                      'Email',
                      _registrationData!.email,
                    ),
                    const SizedBox(height: 12),
                    _buildResultRow(
                      Icons.lock_outline,
                      'Mật khẩu',
                      '•' * _registrationData!.password.length,
                    ),
                    const SizedBox(height: 12),
                    _buildResultRow(
                      Icons.location_city_outlined,
                      'Tỉnh/Thành phố',
                      _registrationData!.province,
                    ),
                    const SizedBox(height: 12),
                    _buildResultRow(
                      Icons.wc_outlined,
                      'Giới tính',
                      _registrationData!.gender.label,
                    ),
                    const SizedBox(height: 12),
                    _buildResultRow(
                      Icons.check_circle_outline,
                      'Đồng ý điều khoản',
                      _registrationData!.agreedToTerms ? 'Có' : 'Không',
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox(key: ValueKey('empty_result')),
    );
  }

  Widget _buildResultRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.teal.shade700),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.teal.shade800.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal.shade900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
