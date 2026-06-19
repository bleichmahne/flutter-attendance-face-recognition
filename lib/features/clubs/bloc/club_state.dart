part of 'club_bloc.dart';

abstract class ClubState extends Equatable {
  const ClubState();

  @override
  List<Object?> get props => [];
}

class ClubInitial extends ClubState {}

class ClubLoading extends ClubState {}

class ClubLoaded extends ClubState {
  final List<ClassModel> classes;

  const ClubLoaded({required this.classes});

  @override
  List<Object?> get props => [classes];
}

class ClubError extends ClubState {
  final String message;

  const ClubError({required this.message});

  @override
  List<Object?> get props => [message];
}

