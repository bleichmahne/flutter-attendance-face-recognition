part of 'face_recognition_bloc.dart';

abstract class FaceRecognitionState extends Equatable {
  const FaceRecognitionState();

  @override
  List<Object?> get props => [];
}

class FaceRecognitionInitial extends FaceRecognitionState {}

class FaceRecognitionLoading extends FaceRecognitionState {}

class FaceRecognitionUserCreated extends FaceRecognitionState {
  final FaceRecognitionUser user;

  const FaceRecognitionUserCreated({required this.user});

  @override
  List<Object?> get props => [user];
}

class FaceRecognitionUserDeleted extends FaceRecognitionState {}

class FaceRecognitionPhotosUpdated extends FaceRecognitionState {
  final PhotoUpdateResult result;

  const FaceRecognitionPhotosUpdated({required this.result});

  @override
  List<Object?> get props => [result];
}

class FaceRecognitionError extends FaceRecognitionState {
  final String message;

  const FaceRecognitionError({required this.message});

  @override
  List<Object?> get props => [message];
}
