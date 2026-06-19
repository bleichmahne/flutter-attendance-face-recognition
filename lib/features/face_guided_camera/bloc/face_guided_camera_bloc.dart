import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../core/services/face_detection_service.dart';

part 'face_guided_camera_event.dart';
part 'face_guided_camera_state.dart';

class FaceGuidedCameraBloc
    extends Bloc<FaceGuidedCameraEvent, FaceGuidedCameraState> {
  final FaceDetectionService faceDetectionService;

  CameraController? _controller;
  CameraDescription? _camera;
  bool _isProcessing = false;
  int _frameCount = 0;
  DateTime? _poseHoldStartTime;
  FacePose _lastDetectedPose = FacePose.unknown;
  bool _isCapturing = false;

  FaceGuidedCameraBloc({required this.faceDetectionService})
      : super(const FaceGuidedCameraState()) {
    on<InitGuidedCamera>(_onInit);
    on<_FaceDetected>(_onFaceDetected);
    on<_NoFaceDetected>(_onNoFace);
    on<AcceptPhoto>(_onAcceptPhoto);
    on<RetakePhoto>(_onRetake);
    on<ResetGuidedCamera>(_onReset);
  }

  Future<void> _onInit(
    InitGuidedCamera event,
    Emitter<FaceGuidedCameraState> emit,
  ) async {
    emit(state.copyWith(step: GuidedCameraStep.initializing));
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(state.copyWith(
          step: GuidedCameraStep.error,
          error: 'no cameras available',
        ));
        return;
      }

      //use back/main camera for capture
      _camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        _camera!,
        ResolutionPreset.medium,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
        enableAudio: false,
      );

      await _controller!.initialize();
      emit(state.copyWith(
        step: GuidedCameraStep.guiding,
        controller: _controller,
        requiredPose: FaceGuidedCameraState.poseSequence[0],
        currentPoseIndex: 0,
        clearError: true,
      ));

      //start image stream for face detection
      await _controller!.startImageStream(_processImage);
    } catch (e) {
      emit(state.copyWith(
        step: GuidedCameraStep.error,
        error: e.toString(),
      ));
    }
  }

  void _processImage(CameraImage image) {
    _frameCount++;
    if (_frameCount % 3 != 0) return;
    if (_isProcessing || _isCapturing) return;
    _isProcessing = true;

    final rotation = _rotationFromSensor(_camera?.sensorOrientation ?? 0);
    final format = Platform.isAndroid
        ? InputImageFormat.nv21
        : InputImageFormat.bgra8888;

    faceDetectionService
        .detectFromCameraImage(image, rotation, format)
        .then((faces) {
      _isProcessing = false;
      if (isClosed) return;

      if (faces.isEmpty) {
        add(const _NoFaceDetected());
        return;
      }

      //use the largest face
      final face = faces.reduce((a, b) =>
          a.boundingBox.width * a.boundingBox.height >
                  b.boundingBox.width * b.boundingBox.height
              ? a
              : b);

      final pose = _classifyPose(face);
      add(_FaceDetected(
        pose,
        face.boundingBox,
        Size(image.width.toDouble(), image.height.toDouble()),
      ));
    }).catchError((_) {
      _isProcessing = false;
    });
  }

  FacePose _classifyPose(Face face) {
    final yAngle = face.headEulerAngleY ?? 0.0;
    final xAngle = face.headEulerAngleX ?? 0.0;
    final zAngle = face.headEulerAngleZ ?? 0.0;

    //reject if face is too tilted vertically or sideways
    if (xAngle.abs() > 15.0 || zAngle.abs() > 15.0) {
      return FacePose.unknown;
    }

    //front: Y angle within [-10, 10] degrees
    if (yAngle.abs() <= 10.0) {
      return FacePose.front;
    }

    //back camera: image is not mirrored, so subject's left = negative Y
    if (yAngle <= -20.0 && yAngle >= -45.0) {
      return FacePose.left;
    }

    if (yAngle >= 20.0 && yAngle <= 45.0) {
      return FacePose.right;
    }

    return FacePose.unknown;
  }

  Future<void> _onFaceDetected(
    _FaceDetected event,
    Emitter<FaceGuidedCameraState> emit,
  ) async {
    if (state.step != GuidedCameraStep.guiding) return;

    final poseMatches = event.pose == state.requiredPose;

    if (poseMatches) {
      if (_poseHoldStartTime == null || _lastDetectedPose != event.pose) {
        _poseHoldStartTime = DateTime.now();
      }

      final holdDuration = DateTime.now().difference(_poseHoldStartTime!);
      final holdProgress =
          (holdDuration.inMilliseconds / 1000.0).clamp(0.0, 1.0);

      emit(state.copyWith(
        detectedPose: event.pose,
        faceBoundingBox: event.boundingBox,
        imageSize: event.imageSize,
        holdProgress: holdProgress,
      ));

      //auto-capture when held for 1 second
      if (holdProgress >= 1.0 && !_isCapturing) {
        _isCapturing = true;
        await _autoCapture(emit);
      }
    } else {
      _poseHoldStartTime = null;
      emit(state.copyWith(
        detectedPose: event.pose,
        faceBoundingBox: event.boundingBox,
        imageSize: event.imageSize,
        holdProgress: 0.0,
      ));
    }
    _lastDetectedPose = event.pose;
  }

  Future<void> _onNoFace(
    _NoFaceDetected event,
    Emitter<FaceGuidedCameraState> emit,
  ) async {
    if (state.step != GuidedCameraStep.guiding) return;
    _poseHoldStartTime = null;
    _lastDetectedPose = FacePose.unknown;
    emit(state.copyWith(
      holdProgress: 0.0,
      clearFace: true,
    ));
  }

  Future<void> _autoCapture(Emitter<FaceGuidedCameraState> emit) async {
    try {
      emit(state.copyWith(step: GuidedCameraStep.capturing));

      //stop image stream before taking picture
      await _controller!.stopImageStream();
      final image = await _controller!.takePicture();

      final updatedPhotos = List<String>.from(state.capturedPhotos)
        ..add(image.path);

      emit(state.copyWith(
        step: GuidedCameraStep.reviewing,
        capturedPhotos: updatedPhotos,
        holdProgress: 1.0,
      ));
    } catch (e) {
      emit(state.copyWith(
        step: GuidedCameraStep.error,
        error: e.toString(),
      ));
    } finally {
      _isCapturing = false;
    }
  }

  Future<void> _onAcceptPhoto(
    AcceptPhoto event,
    Emitter<FaceGuidedCameraState> emit,
  ) async {
    final nextIndex = state.currentPoseIndex + 1;

    if (nextIndex >= FaceGuidedCameraState.poseSequence.length) {
      //all 3 photos captured
      emit(state.copyWith(
        step: GuidedCameraStep.completed,
        currentPoseIndex: nextIndex,
      ));
      return;
    }

    //advance to next pose
    _poseHoldStartTime = null;
    _lastDetectedPose = FacePose.unknown;
    _isCapturing = false;

    emit(state.copyWith(
      step: GuidedCameraStep.guiding,
      requiredPose: FaceGuidedCameraState.poseSequence[nextIndex],
      currentPoseIndex: nextIndex,
      holdProgress: 0.0,
      clearFace: true,
    ));

    //restart image stream
    try {
      await _controller!.startImageStream(_processImage);
    } catch (e) {
      emit(state.copyWith(
        step: GuidedCameraStep.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onRetake(
    RetakePhoto event,
    Emitter<FaceGuidedCameraState> emit,
  ) async {
    //remove last captured photo
    final updatedPhotos = List<String>.from(state.capturedPhotos);
    if (updatedPhotos.isNotEmpty) {
      updatedPhotos.removeLast();
    }

    _poseHoldStartTime = null;
    _lastDetectedPose = FacePose.unknown;
    _isCapturing = false;

    emit(state.copyWith(
      step: GuidedCameraStep.guiding,
      capturedPhotos: updatedPhotos,
      holdProgress: 0.0,
      clearFace: true,
    ));

    //restart image stream
    try {
      await _controller!.startImageStream(_processImage);
    } catch (e) {
      emit(state.copyWith(
        step: GuidedCameraStep.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onReset(
    ResetGuidedCamera event,
    Emitter<FaceGuidedCameraState> emit,
  ) async {
    await _controller?.stopImageStream().catchError((_) {});
    await _controller?.dispose();
    _controller = null;
    _poseHoldStartTime = null;
    _lastDetectedPose = FacePose.unknown;
    _isProcessing = false;
    _isCapturing = false;
    _frameCount = 0;

    emit(const FaceGuidedCameraState());
  }

  InputImageRotation _rotationFromSensor(int sensorOrientation) {
    switch (sensorOrientation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  @override
  Future<void> close() {
    _controller?.stopImageStream().catchError((_) {});
    _controller?.dispose();
    faceDetectionService.dispose();
    return super.close();
  }
}
