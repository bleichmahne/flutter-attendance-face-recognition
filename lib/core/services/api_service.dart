import '../models/recognition_log.dart';
import '../models/user.dart';
import '../models/class_model.dart';
import '../models/child.dart';
import '../models/course.dart';
import '../models/organization.dart';
import '../models/subscription.dart';
import '../models/visit_history.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/refresh_token_request.dart';
import '../models/refresh_token_response.dart';
import 'dio_client.dart';
import 'api_client.dart';
import 'auth_storage_service.dart';

/// single entry point for app api: dioClient = transport (auth, refresh, retry),
/// apiClient = retrofit endpoint definitions using that dio.
class ApiService {
  late final DioClient _dioClient;
  late final ApiClient _apiClient;
  final AuthStorageService _storageService;

  ApiService({
    String baseUrl = 'http://your-api-host:8080/api/v1',
    required AuthStorageService storageService,
    String? authToken,
  })  : _storageService = storageService {
    _dioClient = DioClient(
      baseUrl: baseUrl,
      storageService: storageService,
      authToken: authToken,
    );
    _apiClient = ApiClient(_dioClient.dio);
    _dioClient.setOnTokenRefreshed((token) {
      //token refresh handled in interceptor
    });
  }

  void setOnTokenRefreshed(Function(String?)? callback) {
    _dioClient.setOnTokenRefreshed(callback);
  }

  void setAuthToken(String? token) {
    _dioClient.setAuthToken(token);
  }

  Future<User> getCurrentUser() async {
    final uuid = await _storageService.getUserId();
    if (uuid == null) {
      throw Exception('no user id in storage');
    }
    return getUser(uuid);
  }

  Future<List<User>> getUsers() async {
    try {
      final httpResponse = await _apiClient.getUsers();
      final response = httpResponse.response;

      if (response.statusCode == 200) {
        final List<dynamic> data = httpResponse.data as List<dynamic>;
        return data.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        final errorBody = httpResponse.data?.toString() ?? 'Unknown error';
        throw Exception(
          'Failed to fetch users: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getUser(String uuid) async {
    try {
      final httpResponse = await _apiClient.getUser(uuid);
      final response = httpResponse.response;

      if (response.statusCode == 200) {
        return User.fromJson(httpResponse.data as Map<String, dynamic>);
      } else {
        final errorBody = httpResponse.data?.toString() ?? 'Unknown error';
        throw Exception(
          'Failed to fetch user: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User> createUser({
    required String name,
    required String username,
    required int organizationId,
  }) async {
    try {
      //Swagger: POST /auth/users/{organization_id}, body optional (auto-generated password)
      final httpResponse = await _apiClient.createUser(
        organizationId,
        {'name': name, 'username': username},
      );
      final response = httpResponse.response;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return User.fromJson(httpResponse.data as Map<String, dynamic>);
      } else {
        final errorBody = httpResponse.data?.toString() ?? 'Unknown error';
        throw Exception(
          'Failed to create user: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateUser(
    String uuid, {
    String? name,
    String? username,
    int? organizationId,
  }) async {
    try {
      final httpResponse = await _apiClient.updateUser(
        uuid,
        {
          if (name != null) 'name': name,
          if (username != null) 'username': username,
          if (organizationId != null) 'organization_id': organizationId,
        },
      );
      final response = httpResponse.response;

      if (response.statusCode == 200) {
        return User.fromJson(httpResponse.data as Map<String, dynamic>);
      } else {
        final errorBody = httpResponse.data?.toString() ?? 'Unknown error';
        throw Exception(
          'Failed to update user: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(String uuid) async {
    try {
      final httpResponse = await _apiClient.deleteUser(uuid);
      final response = httpResponse.response;

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        final errorBody = httpResponse.data?.toString() ?? 'Unknown error';
        throw Exception(
          'Failed to delete user: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final request = LoginRequest(username: username, password: password);
      final httpResponse = await _apiClient.login(request);
      final response = httpResponse.response;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = httpResponse.data as Map<String, dynamic>;
        final loginResponse = LoginResponse.fromJson(responseData);
        final token = loginResponse.effectiveToken;
        final refreshToken = loginResponse.refreshToken;

        if (token != null) {
          _dioClient.setAuthToken(token);
        }

        return {
          'token': token,
          'refresh_token': refreshToken,
          'user': loginResponse.user,
        };
      } else {
        String errorMessage = 'Unknown error';
        try {
          final errorData = httpResponse.data as Map<String, dynamic>?;
          if (errorData != null) {
            errorMessage = errorData['error'] as String? ??
                errorData['message'] as String? ??
                errorData['detail'] as String? ??
                errorMessage;
          }
        } catch (e) {
          errorMessage = httpResponse.data?.toString() ?? 'Login failed with status ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final httpResponse = await _apiClient.refreshToken(request);
      final response = httpResponse.response;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = httpResponse.data as Map<String, dynamic>;
        final refreshResponse = RefreshTokenResponse.fromJson(responseData);
        final token = refreshResponse.effectiveToken;
        final newRefreshToken = refreshResponse.refreshToken;

        if (token != null) {
          _dioClient.setAuthToken(token);
        }

        return {
          'token': token,
          'refresh_token': newRefreshToken ?? refreshToken,
        };
      } else {
        final errorBody = httpResponse.data?.toString() ?? 'Unknown error';
        throw Exception(
          'Failed to refresh token: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final httpResponse = await _apiClient.logout();
      final response = httpResponse.response;
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        _dioClient.setAuthToken(null);
      } else {
        throw Exception('Failed to logout: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  //courses (Swagger)
  Future<List<Course>> getCourses() async {
    try {
      final httpResponse = await _apiClient.getCourses();
      final response = httpResponse.response;
      if (response.statusCode == 200) {
        final List<dynamic> data = httpResponse.data as List<dynamic>;
        return data.map((json) => Course.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to fetch courses: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Course> getCourse(int id) async {
    try {
      final httpResponse = await _apiClient.getCourse(id);
      final response = httpResponse.response;
      if (response.statusCode == 200) {
        return Course.fromJson(httpResponse.data as Map<String, dynamic>);
      }
      throw Exception('Failed to fetch course: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Course>> getCoursesByOrganization(int organizationId) async {
    final all = await getCourses();
    return all.where((c) => c.organizationId == organizationId).toList();
  }

  //classes (Swagger) - used as main list (replaces clubs)
  Future<List<ClassModel>> getClasses() async {
    try {
      final httpResponse = await _apiClient.getClasses();
      final response = httpResponse.response;
      if (response.statusCode == 200) {
        final List<dynamic> data = httpResponse.data as List<dynamic>;
        return data.map((json) => ClassModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to fetch classes: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<ClassModel> getClass(int id) async {
    try {
      final httpResponse = await _apiClient.getClass(id);
      final response = httpResponse.response;
      if (response.statusCode == 200) {
        return ClassModel.fromJson(httpResponse.data as Map<String, dynamic>);
      }
      throw Exception('Failed to fetch class: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ClassModel>> getClassesByCourse(int courseId) async {
    final all = await getClasses();
    return all.where((c) => c.courseId == courseId).toList();
  }

  //children (Swagger) - replaces kids
  Future<List<Child>> getChildren() async {
    try {
      final httpResponse = await _apiClient.getChildren();
      final response = httpResponse.response;
      if (response.statusCode == 200) {
        final List<dynamic> data = httpResponse.data as List<dynamic>;
        return data.map((json) => Child.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to fetch children: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Child> getChild(int id) async {
    try {
      final httpResponse = await _apiClient.getChild(id);
      final response = httpResponse.response;
      if (response.statusCode == 200) {
        return Child.fromJson(httpResponse.data as Map<String, dynamic>);
      }
      throw Exception('Failed to fetch child: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Child?> getChildByKbUuid(String kbUuid) async {
    final children = await getChildren();
    for (final c in children) {
      if (c.kbUuid == kbUuid) return c;
    }
    return null;
  }

  //subscriptions (Swagger) - link child to class; replaces kid-clubs
  Future<List<Subscription>> getSubscriptions() async {
    try {
      final httpResponse = await _apiClient.getSubscriptions();
      final response = httpResponse.response;
      if (response.statusCode == 200) {
        final List<dynamic> data = httpResponse.data as List<dynamic>;
        return data.map((json) => Subscription.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to fetch subscriptions: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Subscription>> getSubscriptionsByClassId(int classId) async {
    final all = await getSubscriptions();
    return all.where((s) => s.classId == classId).toList();
  }

  ///children in a class (from subscriptions; replaces getKidClubsByClub)
  Future<List<Child>> getChildrenInClass(int classId) async {
    final subs = await getSubscriptionsByClassId(classId);
    final childIds = subs.map((s) => s.childId).whereType<int>().toSet().toList();
    if (childIds.isEmpty) return [];
    final children = await getChildren();
    return children.where((c) => c.id != null && childIds.contains(c.id)).toList();
  }

  Future<int?> getSubscriptionIdForChildAndClass(int childId, int classId) async {
    final subs = await getSubscriptions();
    for (final s in subs) {
      if (s.childId == childId && s.classId == classId) return s.id;
    }
    return null;
  }

  //visit-histories (Swagger) - replaces report-cards
  Future<List<VisitHistory>> getVisitHistories() async {
    try {
      final httpResponse = await _apiClient.getVisitHistories();
      final response = httpResponse.response;
      if (response.statusCode == 200) {
        final List<dynamic> data = httpResponse.data as List<dynamic>;
        return data.map((json) => VisitHistory.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to fetch visit-histories: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<VisitHistory>> getVisitHistoriesByChildId(int childId) async {
    final subs = await getSubscriptions();
    final subscriptionIds = subs
        .where((s) => s.childId == childId)
        .map((s) => s.id)
        .whereType<int>()
        .toSet();
    if (subscriptionIds.isEmpty) return [];
    final all = await getVisitHistories();
    final filtered = all
        .where((vh) => vh.subscriptionId != null && subscriptionIds.contains(vh.subscriptionId))
        .toList();
    filtered.sort((a, b) {
      final dateA = a.classDate ?? a.createdDt ?? a.created ?? '';
      final dateB = b.classDate ?? b.createdDt ?? b.created ?? '';
      return dateB.compareTo(dateA);
    });
    return filtered;
  }

  Future<VisitHistory> getVisitHistory(int id) async {
    try {
      final httpResponse = await _apiClient.getVisitHistory(id);
      final response = httpResponse.response;
      if (response.statusCode == 200) {
        return VisitHistory.fromJson(httpResponse.data as Map<String, dynamic>);
      }
      throw Exception('Failed to fetch visit-history: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<VisitHistory> createVisitHistory({
    required int subscriptionId,
    required String classDate,
    int? attendanceId,
    int? hVisitResultId,
    bool? isFarFaces,
  }) async {
    try {
      final body = <String, dynamic>{
        'subscription_id': subscriptionId,
        'class_date': classDate,
        if (attendanceId != null) 'attendance_id': attendanceId,
        if (hVisitResultId != null) 'h_visit_result_id': hVisitResultId,
        if (isFarFaces != null) 'is_far_faces': isFarFaces,
      };
      final httpResponse = await _apiClient.createVisitHistory(body);
      final response = httpResponse.response;
      if (response.statusCode == 200 || response.statusCode == 201) {
        return VisitHistory.fromJson(httpResponse.data as Map<String, dynamic>);
      }
      throw Exception('Failed to create visit-history: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<VisitHistory> updateVisitHistory(int id, Map<String, dynamic> body) async {
    try {
      final httpResponse = await _apiClient.updateVisitHistory(id, body);
      final response = httpResponse.response;
      if (response.statusCode == 200) {
        return VisitHistory.fromJson(httpResponse.data as Map<String, dynamic>);
      }
      throw Exception('Failed to update visit-history: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteVisitHistory(int id) async {
    try {
      final httpResponse = await _apiClient.deleteVisitHistory(id);
      final response = httpResponse.response;
      if (response.statusCode != null && (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw Exception('Failed to delete visit-history: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Organization>> getOrganizations() async {
    try {
      final httpResponse = await _apiClient.getOrganizations();
      final response = httpResponse.response;

      if (response.statusCode == 200) {
        final List<dynamic> data = httpResponse.data as List<dynamic>;
        return data.map((json) => Organization.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        final errorBody = httpResponse.data?.toString() ?? 'Unknown error';
        throw Exception(
          'Failed to fetch organizations: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Organization> getOrganization(int id) async {
    try {
      final httpResponse = await _apiClient.getOrganization(id);
      final response = httpResponse.response;

      if (response.statusCode == 200) {
        return Organization.fromJson(httpResponse.data as Map<String, dynamic>);
      } else {
        final errorBody = httpResponse.data?.toString() ?? 'Unknown error';
        throw Exception(
          'Failed to fetch organization: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Organization> createOrganization({required String name}) async {
    try {
      final httpResponse = await _apiClient.createOrganization({'name': name});
      final response = httpResponse.response;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Organization.fromJson(httpResponse.data as Map<String, dynamic>);
      } else {
        final errorBody = httpResponse.data?.toString() ?? 'Unknown error';
        throw Exception(
          'Failed to create organization: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Organization> updateOrganization(int id, {String? name}) async {
    try {
      final httpResponse = await _apiClient.updateOrganization(
        id,
        {if (name != null) 'name': name},
      );
      final response = httpResponse.response;

      if (response.statusCode == 200) {
        return Organization.fromJson(httpResponse.data as Map<String, dynamic>);
      } else {
        final errorBody = httpResponse.data?.toString() ?? 'Unknown error';
        throw Exception(
          'Failed to update organization: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteOrganization(int id) async {
    try {
      final httpResponse = await _apiClient.deleteOrganization(id);
      final response = httpResponse.response;

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        final errorBody = httpResponse.data?.toString() ?? 'Unknown error';
        throw Exception(
          'Failed to delete organization: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  //recognition-logs (Swagger) - no auth required
  Future<List<RecognitionLog>> getRecognitionLogs() async {
    try {
      final httpResponse = await _apiClient.getRecognitionLogs();
      final response = httpResponse.response;
      if (response.statusCode == 200) {
        final List<dynamic> data = httpResponse.data as List<dynamic>;
        return data.map((json) => RecognitionLog.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to fetch recognition-logs: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<RecognitionLog> getRecognitionLog(int id) async {
    try {
      final httpResponse = await _apiClient.getRecognitionLog(id);
      final response = httpResponse.response;
      if (response.statusCode == 200) {
        return RecognitionLog.fromJson(httpResponse.data as Map<String, dynamic>);
      }
      throw Exception('Failed to fetch recognition-log: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  //recognition logs filtered by child uuid, sorted newest first
  Future<List<RecognitionLog>> getRecognitionLogsByUuid(String uuid) async {
    final all = await getRecognitionLogs();
    final filtered = all.where((log) => log.uuid == uuid).toList();
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filtered;
  }

}
