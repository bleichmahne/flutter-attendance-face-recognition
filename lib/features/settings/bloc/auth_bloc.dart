import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/models/user.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_storage_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;
  final AuthStorageService storageService;

  AuthBloc({required this.apiService, AuthStorageService? storageService})
    : storageService = storageService ?? AuthStorageService(),
      super(AuthInitial()) {
    on<LoadUser>(_onLoadUser);
    on<Login>(_onLogin);
    on<RefreshToken>(_onRefreshToken);
    on<Logout>(_onLogout);
  }

  Future<void> _onLoadUser(LoadUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await storageService.getToken();
      if (token == null) {
        emit(AuthUnauthenticated());
        return;
      }
      apiService.setAuthToken(token);

      var user = await storageService.getUser();
      if (user == null) {
        final userId = await storageService.getUserId();
        if (userId != null) {
          user = await apiService.getUser(userId);
          await storageService.saveUser(user);
        }
      }
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        await storageService.clearAll();
        apiService.setAuthToken(null);
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      await storageService.clearAll();
      apiService.setAuthToken(null);
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(Login event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await apiService.login(event.username, event.password);
      final token = response['token'] as String?;
      final refreshToken = response['refresh_token'] as String?;
      final user = response['user'] as User?;

      if (token != null) {
        await storageService.saveToken(token);
        await storageService.savePassword(event.password);
        apiService.setAuthToken(token);
      }

      if (refreshToken != null) {
        await storageService.saveRefreshToken(refreshToken);
      }

      if (user != null) {
        await storageService.saveUser(user);
        emit(AuthAuthenticated(user: user));
      } else {
        final userId = await storageService.getUserId();
        if (userId != null) {
          final fetchedUser = await apiService.getUser(userId);
          await storageService.saveUser(fetchedUser);
          emit(AuthAuthenticated(user: fetchedUser));
        } else {
          emit(AuthError(message: 'login did not return user'));
        }
      }
    } catch (e) {
      // // Extract clean error message
      // String errorMessage = e.toString();
      // // Remove "Exception: " prefix if present
      // if (errorMessage.startsWith('DioException: ')) {
      //   errorMessage = errorMessage.substring(11);
      // }
      // // Ensure we emit the error state to stop loading
      // emit(AuthError(message: errorMessage));
      emit(AuthError(message: 'Login request failed, please try again later'));
    }
  }

  Future<void> _onRefreshToken(
    RefreshToken event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthTokenRefreshing());
    try {
      final refreshToken = await storageService.getRefreshToken();
      if (refreshToken == null) {
        emit(AuthUnauthenticated());
        return;
      }

      final response = await apiService.refreshToken(refreshToken);
      final token = response['token'] as String?;
      final newRefreshToken = response['refresh_token'] as String?;

      if (token != null) {
        await storageService.saveToken(token);
        apiService.setAuthToken(token);
      }

      if (newRefreshToken != null) {
        await storageService.saveRefreshToken(newRefreshToken);
      }

      emit(AuthTokenRefreshed());
    } catch (e) {
      // If refresh fails, clear tokens and logout
      await storageService.clearAll();
      apiService.setAuthToken(null);
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogout(Logout event, Emitter<AuthState> emit) async {
    try {
      await apiService.logout();
      await storageService.clearAll();
      apiService.setAuthToken(null);
      emit(AuthUnauthenticated());
    } catch (e) {
      // Even if logout fails, clear local tokens
      await storageService.clearAll();
      apiService.setAuthToken(null);
      emit(AuthUnauthenticated());
    }
  }
}
