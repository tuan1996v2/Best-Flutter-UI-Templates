import 'dart:io';
import 'package:best_flutter_ui_templates/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../model/User.dart';

class UserAPIService {
  // Base URL của API, thay đổi theo server thực tế
  // Ví dụ: http://10.0.2.2:3000 cho Android Emulator kết nối tới localhost
  static const String baseUrl =
      'https://my-json-server.typicode.com/tuan1996v2/testFlutter';
  // static const String baseUrl = 'http://10.0.2.2:3000/api';

  static final UserAPIService instance = UserAPIService._init();
  late final Dio _dio;

  UserAPIService._init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Thêm PrettyDioLogger để log request/response trực quan, dễ nhìn nhất
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  // 1. GET - Lấy danh sách người dùng
  Future<List<User>> getAllUsers() async {
    try {
      final response = await _dio.get('/users');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => User.fromMap(json)).toList();
      }
      throw Exception(
        'Không thể tải danh sách người dùng: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 2. GET - Lấy chi tiết một người dùng theo ID
  Future<User> getUserById(int id) async {
    try {
      final response = await _dio.get('/users/$id');
      if (response.statusCode == 200) {
        return User.fromMap(response.data);
      }
      throw Exception('Không tìm thấy người dùng');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 3. POST - Thêm người dùng mới
  // Hỗ trợ truyền Multipart (FormData) nếu có hình ảnh avatar local
  Future<User> createUser(User user) async {
    try {
      Response response;

      if (user.avatar != null &&
          user.avatar!.isNotEmpty &&
          !user.avatar!.startsWith('http')) {
        // Nếu avatar là đường dẫn file cục bộ, dùng FormData để gửi multipart/form-data
        final File file = File(user.avatar!);
        if (await file.exists()) {
          final String fileName = file.path.split('/').last;
          final formData = FormData.fromMap({
            'name': user.name,
            'email': user.email,
            'phone': user.phone,
            'dateOfBirth': user.dateOfBirth.toIso8601String(),
            'avatar': await MultipartFile.fromFile(
              file.path,
              filename: fileName,
            ),
          });

          response = await _dio.post(
            '/users',
            data: formData,
            options: Options(contentType: 'multipart/form-data'),
          );
        } else {
          // File không tồn tại, gửi JSON thông thường
          response = await _dio.post('/users', data: user.toMap());
        }
      } else {
        // Gửi qua JSON raw
        response = await _dio.post('/users', data: user.toMap());
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return User.fromMap(response.data);
      }
      throw Exception('Thêm người dùng thất bại: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 4. PUT - Cập nhật thông tin người dùng
  Future<User> updateUser(User user) async {
    try {
      Response response;
      final int? id = user.id;
      if (id == null) {
        throw Exception('Không thể cập nhật người dùng không có ID');
      }

      if (user.avatar != null &&
          user.avatar!.isNotEmpty &&
          !user.avatar!.startsWith('http')) {
        // Nếu cập nhật kèm avatar mới là file cục bộ
        final File file = File(user.avatar!);
        if (await file.exists()) {
          final String fileName = file.path.split('/').last;
          final formData = FormData.fromMap({
            'id': id,
            'name': user.name,
            'email': user.email,
            'phone': user.phone,
            'dateOfBirth': user.dateOfBirth.toIso8601String(),
            'avatar': await MultipartFile.fromFile(
              file.path,
              filename: fileName,
            ),
          });

          response = await _dio.put(
            '/users/$id',
            data: formData,
            options: Options(contentType: 'multipart/form-data'),
          );
        } else {
          response = await _dio.put('/users/$id', data: user.toMap());
        }
      } else {
        response = await _dio.put('/users/$id', data: user.toMap());
      }

      if (response.statusCode == 200) {
        return User.fromMap(response.data);
      }
      throw Exception('Cập nhật người dùng thất bại: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 5. DELETE - Xoá người dùng theo ID
  Future<void> deleteUser(int id) async {
    try {
      final response = await _dio.delete('/users/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Xoá người dùng thất bại: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Xử lý lỗi DioException thân thiện hơn
  Exception _handleDioError(DioException e) {
    String errorMessage = 'Đã xảy ra lỗi kết nối mạng.';
    if (e.response != null) {
      errorMessage =
          'Lỗi từ Server (${e.response?.statusCode}): ${e.response?.data?['message'] ?? e.response?.statusMessage}';
    } else {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'Kết nối tới máy chủ hết hạn (Connection Timeout).';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Không nhận được dữ liệu phản hồi (Receive Timeout).';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = 'Gửi dữ liệu tới máy chủ hết hạn (Send Timeout).';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Yêu cầu kết nối bị huỷ.';
          break;
        default:
          errorMessage = 'Lỗi không xác định: ${e.message}';
          break;
      }
    }
    return Exception(errorMessage);
  }
}
