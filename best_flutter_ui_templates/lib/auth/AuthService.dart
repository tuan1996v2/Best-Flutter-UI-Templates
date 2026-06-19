import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:best_flutter_ui_templates/utils/logger.dart';

/// AuthService - Dịch vụ xác thực người dùng
/// Sử dụng FlutterSecureStorage để lưu trữ thông tin đăng nhập an toàn
/// Sử dụng LocalAuthentication để xác thực sinh trắc học (vân tay/khuôn mặt)
class AuthService {
  // Singleton pattern
  static final AuthService instance = AuthService._init();
  AuthService._init();

  // flutter_secure_storage v10.x: Bỏ encryptedSharedPreferences (deprecated)
  // Dùng AndroidOptions mặc định với custom cipher tự động
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );
  final _auth = LocalAuthentication();

  // Keys lưu trữ
  static const String _keyUsername = 'auth_username';
  static const String _keyPassword = 'auth_password';
  static const String _keyToken = 'auth_token';
  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyBiometricEnabled = 'auth_biometric_enabled';

  // ==================== LƯU TRỮ THÔNG TIN ====================

  /// Lưu thông tin đăng nhập vào bộ nhớ an toàn
  Future<void> saveCredentials({
    required String username,
    required String password,
    String? token,
  }) async {
    await _storage.write(key: _keyUsername, value: username);
    await _storage.write(key: _keyPassword, value: password);
    if (token != null) {
      await _storage.write(key: _keyToken, value: token);
    }
    await _storage.write(key: _keyIsLoggedIn, value: 'true');
    logger.d('AuthService: Đã lưu thông tin đăng nhập cho user: $username');
  }

  /// Bật/tắt xác thực sinh trắc học
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: _keyBiometricEnabled,
      value: enabled.toString(),
    );
  }

  /// Kiểm tra xem đã bật xác thực sinh trắc học chưa
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _keyBiometricEnabled);
    return value == 'true';
  }

  // ==================== ĐỌC THÔNG TIN ====================

  /// Lấy username đã lưu
  Future<String?> getSavedUsername() async {
    return await _storage.read(key: _keyUsername);
  }

  /// Lấy password đã lưu
  Future<String?> getSavedPassword() async {
    return await _storage.read(key: _keyPassword);
  }

  /// Kiểm tra đã đăng nhập trước đó chưa
  Future<bool> isLoggedIn() async {
    final value = await _storage.read(key: _keyIsLoggedIn);
    return value == 'true';
  }

  // ==================== SINH TRẮC HỌC ====================

  /// Kiểm tra thiết bị có hỗ trợ sinh trắc học không
  Future<bool> canUseBiometrics() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (e) {
      logger.e('AuthService: Lỗi kiểm tra sinh trắc học: $e');
      return false;
    }
  }

  /// Lấy danh sách loại sinh trắc học có sẵn
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      logger.e('AuthService: Lỗi lấy danh sách sinh trắc học: $e');
      return [];
    }
  }

  /// Xác thực bằng sinh trắc học (vân tay/khuôn mặt)
  Future<bool> authenticateWithBiometrics() async {
    try {
      final canAuthenticate = await canUseBiometrics();
      if (!canAuthenticate) {
        logger.w('AuthService: Thiết bị không hỗ trợ sinh trắc học');
        return false;
      }

      // local_auth v3.x: Bỏ AuthenticationOptions, dùng tham số trực tiếp
      // persistAcrossBackgrounding thay cho stickyAuth
      final authenticated = await _auth.authenticate(
        localizedReason: 'Xác thực để đăng nhập tài khoản',
        persistAcrossBackgrounding: true,
      );

      logger.d('AuthService: Kết quả xác thực sinh trắc: $authenticated');
      return authenticated;
    } on LocalAuthException catch (e) {
      // local_auth v3.x: Bắt LocalAuthException thay vì PlatformException
      logger.e('AuthService: Lỗi xác thực sinh trắc học [${e.code}]: ${e.description}');
      return false;
    } catch (e) {
      logger.e('AuthService: Lỗi không xác định: $e');
      return false;
    }
  }

  /// Lấy thông tin đăng nhập có bảo vệ bằng sinh trắc học
  Future<Map<String, String?>?> getCredentialsSecurely() async {
    final authenticated = await authenticateWithBiometrics();
    if (authenticated) {
      final username = await _storage.read(key: _keyUsername);
      final password = await _storage.read(key: _keyPassword);
      final token = await _storage.read(key: _keyToken);
      return {
        'username': username,
        'password': password,
        'token': token,
      };
    }
    return null;
  }

  // ==================== ĐĂNG XUẤT ====================

  /// Xoá toàn bộ thông tin đăng nhập
  Future<void> logout() async {
    await _storage.delete(key: _keyUsername);
    await _storage.delete(key: _keyPassword);
    await _storage.delete(key: _keyToken);
    await _storage.write(key: _keyIsLoggedIn, value: 'false');
    logger.d('AuthService: Đã đăng xuất và xoá thông tin');
  }

  /// Xoá toàn bộ dữ liệu lưu trữ
  Future<void> clearAll() async {
    await _storage.deleteAll();
    logger.d('AuthService: Đã xoá toàn bộ dữ liệu lưu trữ');
  }
}
