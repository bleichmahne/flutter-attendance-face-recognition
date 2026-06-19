import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'auth_storage_service.dart';

class DioClient {
  late final Dio _dio;
  final AuthStorageService _storageService;
  Function(String?)? _onTokenRefreshed;
  String? _authToken;
  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})> _pendingRequests = [];

  DioClient({
    String baseUrl = 'http://your-api-host:8080/api/v1',
    AuthStorageService? storageService,
    String? authToken,
  })  : _storageService = storageService ?? AuthStorageService(),
        _authToken = authToken {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(this),
      _TokenRefreshInterceptor(this),
      _RetryInterceptor(this),
      _ErrorInterceptor(),
      _LoggingInterceptor(),
    ]);

    _loadTokenFromStorage();
  }

  Future<void> _loadTokenFromStorage() async {
    if (_authToken == null) {
      final token = await _storageService.getToken();
      if (token != null) {
        _authToken = token;
      }
    }
  }

  Dio get dio => _dio;

  String? get authToken => _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  void setOnTokenRefreshed(Function(String?)? callback) {
    _onTokenRefreshed = callback;
  }

  Future<bool> _handleTokenRefresh() async {
    if (_isRefreshing) {
      return false;
    }

    _isRefreshing = true;
    try {
      final storedRefreshToken = await _storageService.getRefreshToken();
      if (storedRefreshToken == null) {
        _authToken = null;
        await _storageService.clearAll();
        _isRefreshing = false;
        return false;
      }

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': storedRefreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final token = responseData['token'] as String? ??
            responseData['access_token'] as String?;
        final newRefreshToken = responseData['refresh_token'] as String?;

        if (token != null) {
          _authToken = token;
          await _storageService.saveToken(token);
          if (newRefreshToken != null) {
            await _storageService.saveRefreshToken(newRefreshToken);
          }
          _onTokenRefreshed?.call(token);
          _isRefreshing = false;
          return true;
        }
      }
    } catch (e) {
      _authToken = null;
      await _storageService.clearAll();
    }
    _isRefreshing = false;
    return false;
  }

  void _processPendingRequests(bool success) {
    final pending = List.from(_pendingRequests);
    _pendingRequests.clear();

    for (final pendingRequest in pending) {
      if (success) {
        _dio.fetch(pendingRequest.options).then(
          (response) => pendingRequest.handler.resolve(response),
          onError: (error) => pendingRequest.handler.reject(error as DioException),
        );
      } else {
        pendingRequest.handler.reject(
          DioException(
            requestOptions: pendingRequest.options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: pendingRequest.options,
              statusCode: 401,
            ),
          ),
        );
      }
    }
  }
}

class _AuthInterceptor extends Interceptor {
  final DioClient _client;

  _AuthInterceptor(this._client);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;
    final isLoginOrRefresh = path == '/auth/login' || path == '/auth/refresh';
    if (!isLoginOrRefresh && _client._authToken != null) {
      options.headers['Authorization'] = 'Bearer ${_client._authToken}';
    }
    handler.next(options);
  }
}

class _TokenRefreshInterceptor extends Interceptor {
  final DioClient _client;

  _TokenRefreshInterceptor(this._client);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final requestOptions = err.requestOptions;

      if (requestOptions.path == '/login' ||
          requestOptions.path == '/auth/refresh') {
        handler.reject(err);
        return;
      }

      if (_client._isRefreshing) {
        _client._pendingRequests.add((options: requestOptions, handler: handler));
        return;
      }

      final refreshed = await _client._handleTokenRefresh();
      if (refreshed) {
        requestOptions.headers['Authorization'] =
            'Bearer ${_client._authToken}';
        try {
          final response = await _client._dio.fetch(requestOptions);
          handler.resolve(response);
        } catch (e) {
          handler.reject(e as DioException);
        }
        _client._processPendingRequests(true);
      } else {
        _client._processPendingRequests(false);
        handler.reject(err);
      }
    } else {
      handler.next(err);
    }
  }
}

class _RetryInterceptor extends Interceptor {
  final DioClient _client;

  _RetryInterceptor(this._client);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final maxRetries = 3;
    int attempt = 0;
    DioException? lastException = err;

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      while (attempt < maxRetries) {
        try {
          await Future.delayed(
            Duration(milliseconds: 1000 * (1 << attempt)),
          );
          final response = await _client._dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          lastException = e as DioException;
          attempt++;
        }
      }
    }

    if (err.response?.statusCode != null &&
        err.response!.statusCode! >= 500 &&
        err.response!.statusCode! < 600) {
      while (attempt < maxRetries) {
        try {
          await Future.delayed(
            Duration(milliseconds: 1000 * (1 << attempt)),
          );
          final response = await _client._dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          lastException = e as DioException;
          attempt++;
        }
      }
    }

    if (lastException != null) {
      handler.reject(lastException);
    } else {
      handler.reject(err);
    }
  }
}

class _ApiError extends DioException {
  final String _cleanMessage;

  _ApiError({
    required super.requestOptions,
    super.response,
    super.type,
    required String cleanMessage,
  }) : _cleanMessage = cleanMessage;

  @override
  String toString() => _cleanMessage;
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err is _ApiError) {
      handler.reject(err);
      return;
    }

    if (err.response != null) {
      final data = err.response!.data;

      String errorMessage = 'api error';
      if (data is Map<String, dynamic>) {
        errorMessage = data['error'] as String? ??
            data['message'] as String? ??
            data['detail'] as String? ??
            'api error';
      } else if (data is String && data.isNotEmpty) {
        errorMessage = data;
      }

      handler.reject(_ApiError(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        cleanMessage: errorMessage,
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
      handler.reject(_ApiError(
        requestOptions: err.requestOptions,
        type: err.type,
        cleanMessage: message,
      ));
    }
  }
}

class _LoggingInterceptor extends Interceptor {
  static const int _maxBodyLogLength = 2000;

  String _redactAuth(Map<String, dynamic>? headers) {
    if (headers == null) return 'null';
    final copy = Map<String, dynamic>.from(headers);
    if (copy.containsKey('Authorization')) {
      copy['Authorization'] = 'Bearer ***';
    }
    return copy.toString();
  }

  String _bodyPreview(dynamic data) {
    if (data == null) return 'null';
    if (data is List<int>) return '<binary ${data.length} bytes>';
    if (data is FormData) {
      final parts = <String>[];
      for (final e in data.fields) {
        parts.add('${e.key}=${e.value.length > 100 ? "${e.value.substring(0, 100)}..." : e.value}');
      }
      for (final f in data.files) {
        parts.add('${f.key}: MultipartFile(${f.value.filename})');
      }
      return 'FormData(${parts.join(", ")})';
    }
    final str = data.toString();
    if (str.length > _maxBodyLogLength) {
      return '${str.substring(0, _maxBodyLogLength)}... (truncated)';
    }
    return str;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final uri = options.uri.toString();
      debugPrint('=== API REQUEST ===');
      debugPrint('${options.method} $uri');
      debugPrint('headers: ${_redactAuth(options.headers)}');
      if (options.queryParameters.isNotEmpty) {
        debugPrint('query: ${options.queryParameters}');
      }
      if (options.data != null) {
        debugPrint('body: ${_bodyPreview(options.data)}');
      }
      debugPrint('==================');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('=== API RESPONSE ===');
      debugPrint(
        '${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}',
      );
      debugPrint('body: ${_bodyPreview(response.data)}');
      debugPrint('===================');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('=== API ERROR ===');
      debugPrint(
        '${err.response?.statusCode} ${err.requestOptions.method} ${err.requestOptions.uri}',
      );
      debugPrint('body: ${_bodyPreview(err.response?.data)}');
      debugPrint('message: ${err.message}');
      debugPrint('===============');
    }
    handler.next(err);
  }
}
