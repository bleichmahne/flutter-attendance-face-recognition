part of 'face_guided_camera_bloc.dart';

enum FacePose { front, left, right, unknown }

enum GuidedCameraStep {
  initializing,
  guiding,
  capturing,
  reviewing,
  completed,
  error,
}

class FaceGuidedCameraState extends Equatable {
  final GuidedCameraStep step;
  final FacePose requiredPose;
  final FacePose? detectedPose;
  final double holdProgress;
  final Rect? faceBoundingBox;
  final Size? imageSize;
  final List<String> capturedPhotos;
  final int currentPoseIndex;
  final String? error;
  final CameraController? controller;

  const FaceGuidedCameraState({
    this.step = GuidedCameraStep.initializing,
    this.requiredPose = FacePose.front,
    this.detectedPose,
    this.holdProgress = 0.0,
    this.faceBoundingBox,
    this.imageSize,
    this.capturedPhotos = const [],
    this.currentPoseIndex = 0,
    this.error,
    this.controller,
  });

  static const poseSequence = [FacePose.front, FacePose.left, FacePose.right];

  bool get isAllCaptured => capturedPhotos.length >= 3;

  FaceGuidedCameraState copyWith({
    GuidedCameraStep? step,
    FacePose? requiredPose,
    FacePose? detectedPose,
    double? holdProgress,
    Rect? faceBoundingBox,
    Size? imageSize,
    List<String>? capturedPhotos,
    int? currentPoseIndex,
    String? error,
    CameraController? controller,
    bool clearFace = false,
    bool clearError = false,
  }) {
    return FaceGuidedCameraState(
      step: step ?? this.step,
      requiredPose: requiredPose ?? this.requiredPose,
      detectedPose: clearFace ? null : (detectedPose ?? this.detectedPose),
      holdProgress: holdProgress ?? this.holdProgress,
      faceBoundingBox: clearFace ? null : (faceBoundingBox ?? this.faceBoundingBox),
      imageSize: imageSize ?? this.imageSize,
      capturedPhotos: capturedPhotos ?? this.capturedPhotos,
      currentPoseIndex: currentPoseIndex ?? this.currentPoseIndex,
      error: clearError ? null : (error ?? this.error),
      controller: controller ?? this.controller,
    );
  }

  @override
  List<Object?> get props => [
        step,
        requiredPose,
        detectedPose,
        holdProgress,
        faceBoundingBox,
        imageSize,
        capturedPhotos,
        currentPoseIndex,
        error,
        controller,
      ];
}
