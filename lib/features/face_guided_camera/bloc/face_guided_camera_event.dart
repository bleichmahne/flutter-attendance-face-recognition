part of 'face_guided_camera_bloc.dart';

abstract class FaceGuidedCameraEvent extends Equatable {
  const FaceGuidedCameraEvent();

  @override
  List<Object?> get props => [];
}

//initialize camera and start image stream
class InitGuidedCamera extends FaceGuidedCameraEvent {
  const InitGuidedCamera();
}

//internal: face detected in frame with pose classification
class _FaceDetected extends FaceGuidedCameraEvent {
  final FacePose pose;
  final Rect? boundingBox;
  final Size imageSize;

  const _FaceDetected(this.pose, this.boundingBox, this.imageSize);

  @override
  List<Object?> get props => [pose, boundingBox, imageSize];
}

//internal: no face found in frame
class _NoFaceDetected extends FaceGuidedCameraEvent {
  const _NoFaceDetected();
}

//user confirms captured photo and moves to next pose
class AcceptPhoto extends FaceGuidedCameraEvent {
  const AcceptPhoto();
}

//user wants to retake current pose photo
class RetakePhoto extends FaceGuidedCameraEvent {
  const RetakePhoto();
}

//reset entire guided camera session
class ResetGuidedCamera extends FaceGuidedCameraEvent {
  const ResetGuidedCamera();
}
