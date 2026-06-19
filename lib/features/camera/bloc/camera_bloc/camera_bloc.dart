import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:camera/camera.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc() : super(CameraInitial()) {
    on<InitializeCamera>(_onInitializeCamera);
    on<CapturePhoto>(_onCapturePhoto);
    on<ResetCamera>(_onResetCamera);
  }

  CameraController? _controller;

  Future<void> _onInitializeCamera(
    InitializeCamera event,
    Emitter<CameraState> emit,
  ) async {
    emit(CameraLoading());
    try {
      //dispose old controller to avoid leaks and race conditions
      //wrapped separately so a failed dispose doesn't block new init
      if (_controller != null) {
        try {
          await _controller!.dispose();
        } catch (_) {}
        _controller = null;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(CameraError(message: 'No cameras available'));
        return;
      }

      //prefer back/main camera; fall back to whatever is available
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
      );
      await controller.initialize();
      _controller = controller;
      emit(CameraReady(controller: controller));
    } catch (e) {
      emit(CameraError(message: e.toString()));
    }
  }

  Future<void> _onCapturePhoto(
    CapturePhoto event,
    Emitter<CameraState> emit,
  ) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      emit(CameraError(message: 'Camera not initialized'));
      return;
    }

    try {
      emit(CameraCapturing());
      final image = await _controller!.takePicture();
      emit(CameraCaptured(imagePath: image.path));
    } catch (e) {
      emit(CameraError(message: e.toString()));
    }
  }

  Future<void> _onResetCamera(
    ResetCamera event,
    Emitter<CameraState> emit,
  ) async {
    await _controller?.dispose();
    _controller = null;
    emit(CameraInitial());
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}

