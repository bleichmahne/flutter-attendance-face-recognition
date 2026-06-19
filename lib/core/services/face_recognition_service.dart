import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/face_recognition_user.dart';
import '../models/face_recognition_result.dart';
import '../models/photo_update_result.dart';
import '../models/verification_result.dart';

//face API (8000): create/update/delete face users, get users, stats, health; POST /recognize for attendance
class FaceRecognitionService {
  final String baseUrl;
  final Dio _dio;

  FaceRecognitionService({
    this.baseUrl = 'http://your-api-host:8000',
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: {'Content-Type': 'application/json'},
              ),
            ) {
    _dio.interceptors.add(_CleanErrorInterceptor());
  }

  dynamic _normalizeJson(dynamic data) {
    if (data is String) {
      return json.decode(data);
    }
    return data;
  }

  /// GET /user/{uuid}/photos — returns the URL of the first registered photo,
  /// or null if the user has no registered photos.
  Future<String?> getFirstRegistrationPhotoUrl(String uuid) async {
    try {
      final response = await _dio.get('/user/$uuid/photos');
      if (response.statusCode != 200) return null;
      final data = _normalizeJson(response.data) as Map<String, dynamic>;
      final photos = data['photos'] as List<dynamic>?;
      if (photos == null || photos.isEmpty) return null;
      final first = photos.first as Map<String, dynamic>;
      final filename = first['filename'] as String?;
      if (filename == null) return null;
      return '$baseUrl/user/$uuid/photos/$filename';
    } catch (_) {
      return null;
    }
  }

  Future<FaceRecognitionUser> createUser(String uuid, List<File> photos) async {
    try {
      final formData = FormData.fromMap({
        'uuid': uuid,
        'photos': [
          for (final photo in photos)
            await MultipartFile.fromFile(photo.path, filename: photo.uri.pathSegments.isNotEmpty ? photo.uri.pathSegments.last : null),
        ],
      });

      final response = await _dio.post(
        '/user',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return FaceRecognitionUser.fromJson(
          _normalizeJson(response.data) as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          'Failed to create user: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  Future<List<FaceRecognitionUser>> getUsers() async {
    try {
      final response = await _dio.get('/users');

      if (response.statusCode == 200) {
        final data = _normalizeJson(response.data);
        final List<dynamic> list = data as List<dynamic>;
        return list
            .map((json) => FaceRecognitionUser.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  Future<FaceRecognitionUser> getUser(String uuid) async {
    try {
      final response = await _dio.get('/user/$uuid');

      if (response.statusCode == 200) {
        return FaceRecognitionUser.fromJson(
          _normalizeJson(response.data) as Map<String, dynamic>,
        );
      } else {
        throw Exception('Failed to fetch user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  Future<FaceRecognitionUser> updateUser(
    String uuid, {
    String? name,
    List<File>? photos,
  }) async {
    try {
      final formMap = <String, dynamic>{};
      if (name != null) {
        formMap['name'] = name;
      }
      if (photos != null) {
        formMap['photos'] = [
          for (final photo in photos)
            await MultipartFile.fromFile(photo.path, filename: photo.uri.pathSegments.isNotEmpty ? photo.uri.pathSegments.last : null),
        ];
      }

      final response = await _dio.put(
        '/user/$uuid',
        data: FormData.fromMap(formMap),
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        return FaceRecognitionUser.fromJson(
          _normalizeJson(response.data) as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          'Failed to update user: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  Future<void> deleteUser(String uuid) async {
    try {
      final response = await _dio.delete('/user/$uuid');

      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw Exception('Failed to delete user: $status');
      }
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _dio.get('/stats');

      if (response.statusCode == 200) {
        return _normalizeJson(response.data) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching stats: $e');
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _dio.get('/health');

      if (response.statusCode == 200) {
        return _normalizeJson(response.data) as Map<String, dynamic>;
      } else {
        throw Exception('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking health: $e');
    }
  }

  /// PUT /user/{uuid}/photos — replace all registration photos with identity check
  Future<PhotoUpdateResult> updateUserPhotos(
    String uuid,
    List<File> photos, {
    double threshold = 0.15,
  }) async {
    try {
      final formData = FormData.fromMap({
        'photos': [
          for (final photo in photos)
            await MultipartFile.fromFile(photo.path,
                filename: photo.uri.pathSegments.isNotEmpty
                    ? photo.uri.pathSegments.last
                    : null),
        ],
        'threshold': threshold,
      });

      final response = await _dio.put(
        '/user/$uuid/photos',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        return PhotoUpdateResult.fromJson(
          _normalizeJson(response.data) as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          'Failed to update photos: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      throw Exception('Error updating photos: $e');
    }
  }

  /// POST /recognize — 1:N recognition. App-level contract treats username,
  /// password, and section_id as required (same auth shape as /verify).
  Future<FaceRecognitionResult> recognize(
    File photo, {
    required String username,
    required String password,
    required int sectionId,
    double threshold = 0.8,
  }) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: photo.uri.pathSegments.isNotEmpty ? photo.uri.pathSegments.last : 'photo.jpg',
        ),
        'threshold': threshold,
        'username': username,
        'password': password,
        'section_id': sectionId,
      });

      final response = await _dio.post(
        '/recognize',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        return FaceRecognitionResult.fromJson(
          _normalizeJson(response.data) as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          'Failed to recognize: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      throw Exception('Error recognizing: $e');
    }
  }

  /// POST /verify — 1:1 verification against specific uuid
  Future<VerificationResult> verify(
    File photo, {
    required String uuid,
    required String username,
    required String password,
    required int sectionId,
    double threshold = 0.4,
  }) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: photo.uri.pathSegments.isNotEmpty ? photo.uri.pathSegments.last : 'photo.jpg',
        ),
        'uuid': uuid,
        'username': username,
        'password': password,
        'section_id': sectionId,
        'threshold': threshold,
      });

      final response = await _dio.post(
        '/verify',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        return VerificationResult.fromJson(
          _normalizeJson(response.data) as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          'Failed to verify: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      throw Exception('Error verifying: $e');
    }
  }
}

class _CleanErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      final data = err.response!.data;
      final statusCode = err.response!.statusCode;

      String errorMessage = 'unknown error';
      if (data is Map<String, dynamic>) {
        errorMessage = data['error'] as String? ??
            data['message'] as String? ??
            data['detail'] as String? ??
            data.toString();
      } else if (data is String && data.isNotEmpty) {
        errorMessage = data;
      }

      handler.reject(_FaceApiError(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        cleanMessage: '$statusCode: $errorMessage',
      ));
    } else {
      String message;
      switch (err.type) {
        case DioExceptionType.connectionTimeout:
          message = 'connection timeout';
        case DioExceptionType.sendTimeout:
          message = 'send timeout';
        case DioExceptionType.receiveTimeout:
          message = 'receive timeout';
        case DioExceptionType.connectionError:
          message = 'connection error';
        case DioExceptionType.cancel:
          message = 'request cancelled';
        default:
          message = err.message ?? 'unknown error';
      }
      handler.reject(_FaceApiError(
        requestOptions: err.requestOptions,
        type: err.type,
        cleanMessage: message,
      ));
    }
  }
}

class _FaceApiError extends DioException {
  final String _cleanMessage;

  _FaceApiError({
    required super.requestOptions,
    super.response,
    super.type,
    required String cleanMessage,
  }) : _cleanMessage = cleanMessage;

  @override
  String toString() => _cleanMessage;
}
