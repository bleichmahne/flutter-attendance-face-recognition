part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoadUser extends AuthEvent {
  const LoadUser();
}

class Login extends AuthEvent {
  final String username;
  final String password;

  const Login({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

class RefreshToken extends AuthEvent {
  const RefreshToken();
}

class Logout extends AuthEvent {
  const Logout();
}

