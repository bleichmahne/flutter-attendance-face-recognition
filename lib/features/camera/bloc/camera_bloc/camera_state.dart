part of 'camera_bloc.dart';

abstract class CameraState extends Equatable {
  const CameraState();

  @override
  List<Object?> get props => [];
}

class CameraInitial extends CameraState {}

class CameraLoading extends CameraState {}

class CameraReady extends CameraState {
  final CameraController controller;

  const CameraReady({required this.controller});

  @override
  List<Object?> get props => [controller];
}

class CameraCapturing extends CameraState {}

class CameraCaptured extends CameraState {
  final String imagePath;

  const CameraCaptured({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class CameraError extends CameraState {
  final String message;

  const CameraError({required this.message});

  @override
  List<Object?> get props => [message];
}

