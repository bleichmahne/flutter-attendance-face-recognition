part of 'camera_bloc.dart';

abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCamera extends CameraEvent {
  const InitializeCamera();
}

class CapturePhoto extends CameraEvent {
  const CapturePhoto();
}

class ResetCamera extends CameraEvent {
  const ResetCamera();
}

