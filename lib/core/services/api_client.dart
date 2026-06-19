import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/login_request.dart';
import '../models/refresh_token_request.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  //auth endpoints
  @POST('/auth/login')
  Future<HttpResponse<dynamic>> login(@Body() LoginRequest request);

  @POST('/auth/refresh')
  Future<HttpResponse<dynamic>> refreshToken(
    @Body() RefreshTokenRequest request,
  );

  @POST('/auth/logout')
  Future<HttpResponse<dynamic>> logout();

  //upload image to main API (8080/api/v1/upload), form field "image"
  @POST('/upload')
  @MultiPart()
  Future<HttpResponse<dynamic>> uploadAttendanceImage(
    @Part() MultipartFile image,
  );

  //attendance endpoints (Swagger: /attendances)
  @GET('/attendances')
  Future<HttpResponse<dynamic>> getAttendances();

  @POST('/attendances')
  Future<HttpResponse<dynamic>> createAttendance(@Body() Map<String, dynamic> body);

  @GET('/attendances/{id}')
  Future<HttpResponse<dynamic>> getAttendance(@Path('id') int id);

  @PUT('/attendances/{id}')
  Future<HttpResponse<dynamic>> updateAttendance(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/attendances/{id}')
  Future<HttpResponse<dynamic>> deleteAttendance(@Path('id') int id);

  //user endpoints (Swagger: GET /auth/users, POST /auth/users/{organization_id})
  @GET('/auth/users')
  Future<HttpResponse<dynamic>> getUsers();

  @GET('/users/{uuid}')
  Future<HttpResponse<dynamic>> getUser(@Path('uuid') String uuid);

  @POST('/auth/users/{organization_id}')
  Future<HttpResponse<dynamic>> createUser(
    @Path('organization_id') int organizationId,
    @Body() Map<String, dynamic>? body,
  );

  @PUT('/users/{uuid}')
  Future<HttpResponse<dynamic>> updateUser(
    @Path('uuid') String uuid,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/users/{uuid}')
  Future<HttpResponse<dynamic>> deleteUser(@Path('uuid') String uuid);

  //visit-histories endpoints (Swagger: /visit-histories)
  @GET('/visit-histories')
  Future<HttpResponse<dynamic>> getVisitHistories();

  @GET('/visit-histories/{id}')
  Future<HttpResponse<dynamic>> getVisitHistory(@Path('id') int id);

  @POST('/visit-histories')
  Future<HttpResponse<dynamic>> createVisitHistory(@Body() Map<String, dynamic> body);

  @PUT('/visit-histories/{id}')
  Future<HttpResponse<dynamic>> updateVisitHistory(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/visit-histories/{id}')
  Future<HttpResponse<dynamic>> deleteVisitHistory(@Path('id') int id);

  //organization endpoints
  @GET('/organizations')
  Future<HttpResponse<dynamic>> getOrganizations();

  @GET('/organizations/{id}')
  Future<HttpResponse<dynamic>> getOrganization(@Path('id') int id);

  @POST('/organizations')
  Future<HttpResponse<dynamic>> createOrganization(@Body() Map<String, dynamic> body);

  @PUT('/organizations/{id}')
  Future<HttpResponse<dynamic>> updateOrganization(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/organizations/{id}')
  Future<HttpResponse<dynamic>> deleteOrganization(@Path('id') int id);

  //applications (Swagger: /applications)
  @GET('/applications')
  Future<HttpResponse<dynamic>> getApplications();

  @POST('/applications')
  Future<HttpResponse<dynamic>> createApplication(@Body() Map<String, dynamic> body);

  @GET('/applications/{id}')
  Future<HttpResponse<dynamic>> getApplication(@Path('id') int id);

  @PUT('/applications/{id}')
  Future<HttpResponse<dynamic>> updateApplication(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/applications/{id}')
  Future<HttpResponse<dynamic>> deleteApplication(@Path('id') int id);

  //children (Swagger: /children)
  @GET('/children')
  Future<HttpResponse<dynamic>> getChildren();

  @POST('/children')
  Future<HttpResponse<dynamic>> createChild(@Body() Map<String, dynamic> body);

  @GET('/children/{id}')
  Future<HttpResponse<dynamic>> getChild(@Path('id') int id);

  @PUT('/children/{id}')
  Future<HttpResponse<dynamic>> updateChild(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/children/{id}')
  Future<HttpResponse<dynamic>> deleteChild(@Path('id') int id);

  //classes (Swagger: /classes)
  @GET('/classes')
  Future<HttpResponse<dynamic>> getClasses();

  @POST('/classes')
  Future<HttpResponse<dynamic>> createClass(@Body() Map<String, dynamic> body);

  @GET('/classes/{id}')
  Future<HttpResponse<dynamic>> getClass(@Path('id') int id);

  @PUT('/classes/{id}')
  Future<HttpResponse<dynamic>> updateClass(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/classes/{id}')
  Future<HttpResponse<dynamic>> deleteClass(@Path('id') int id);

  //courses (Swagger: /courses)
  @GET('/courses')
  Future<HttpResponse<dynamic>> getCourses();

  @POST('/courses')
  Future<HttpResponse<dynamic>> createCourse(@Body() Map<String, dynamic> body);

  @GET('/courses/{id}')
  Future<HttpResponse<dynamic>> getCourse(@Path('id') int id);

  @PUT('/courses/{id}')
  Future<HttpResponse<dynamic>> updateCourse(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/courses/{id}')
  Future<HttpResponse<dynamic>> deleteCourse(@Path('id') int id);

  //subscriptions (Swagger: /subscriptions)
  @GET('/subscriptions')
  Future<HttpResponse<dynamic>> getSubscriptions();

  @POST('/subscriptions')
  Future<HttpResponse<dynamic>> createSubscription(@Body() Map<String, dynamic> body);

  @GET('/subscriptions/{id}')
  Future<HttpResponse<dynamic>> getSubscription(@Path('id') int id);

  @PUT('/subscriptions/{id}')
  Future<HttpResponse<dynamic>> updateSubscription(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/subscriptions/{id}')
  Future<HttpResponse<dynamic>> deleteSubscription(@Path('id') int id);

  //recognition-logs (Swagger: /recognition-logs)
  @GET('/recognition-logs')
  Future<HttpResponse<dynamic>> getRecognitionLogs();

  @GET('/recognition-logs/{id}')
  Future<HttpResponse<dynamic>> getRecognitionLog(@Path('id') int id);
}
