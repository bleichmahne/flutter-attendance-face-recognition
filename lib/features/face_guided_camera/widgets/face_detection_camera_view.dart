import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../core/services/face_detection_service.dart';
import 'face_overlay_painter.dart';

//camera preview with real-time face detection overlay.
//wraps CameraPreview and draws face bounding box on detected faces.
//call [stopDetection] before capturing a photo, [startDetection] after.
class FaceDetectionCameraView extends StatefulWidget {
  final CameraController controller;
  final Widget? overlay;
  final bool isFrontCamera;

  const FaceDetectionCameraView({
    super.key,
    required this.controller,
    this.overlay,
    this.isFrontCamera = false,
  });

  @override
  State<FaceDetectionCameraView> createState() =>
      FaceDetectionCameraViewState();
}

class FaceDetectionCameraViewState extends State<FaceDetectionCameraView> {
  final FaceDetectionService _detectionService = FaceDetectionService();
  bool _isProcessing = false;
  int _frameCount = 0;
  Rect? _faceBoundingBox;
  Size? _imageSize;
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _startStream();
  }

  @override
  void dispose() {
    _stopStream();
    _detectionService.dispose();
    super.dispose();
  }

  void _startStream() {
    if (_isStreaming || !widget.controller.value.isInitialized) return;
    try {
      widget.controller.startImageStream(_processImage);
      _isStreaming = true;
    } catch (_) {}
  }

  void _stopStream() {
    if (!_isStreaming) return;
    try {
      widget.controller.stopImageStream();
      _isStreaming = false;
    } catch (_) {}
  }

  //stop detection before capture to avoid conflicts
  void stopDetection() {
    _stopStream();
  }

  //resume detection after capture
  void startDetection() {
    _startStream();
  }

  void _processImage(CameraImage image) {
    _frameCount++;
    if (_frameCount % 3 != 0) return;
    if (_isProcessing) return;
    _isProcessing = true;

    final sensorOrientation =
        widget.controller.description.sensorOrientation;
    final rotation = _rotationFromSensor(sensorOrientation);
    final format = Platform.isAndroid
        ? InputImageFormat.nv21
        : InputImageFormat.bgra8888;

    _detectionService
        .detectFromCameraImage(image, rotation, format)
        .then((faces) {
      _isProcessing = false;
      if (!mounted) return;

      if (faces.isEmpty) {
        if (_faceBoundingBox != null) {
          setState(() {
            _faceBoundingBox = null;
            _imageSize = null;
          });
        }
        return;
      }

      //use largest face
      final face = faces.reduce((a, b) =>
          a.boundingBox.width * a.boundingBox.height >
                  b.boundingBox.width * b.boundingBox.height
              ? a
              : b);

      setState(() {
        _faceBoundingBox = face.boundingBox;
        _imageSize =
            Size(image.width.toDouble(), image.height.toDouble());
      });
    }).catchError((_) {
      _isProcessing = false;
    });
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
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(widget.controller),
        CustomPaint(
          painter: FaceOverlayPainter(
            faceBoundingBox: _faceBoundingBox,
            imageSize: _imageSize,
            poseMatches: _faceBoundingBox != null,
            isFrontCamera: widget.isFrontCamera,
          ),
        ),
        if (widget.overlay != null) widget.overlay!,
      ],
    );
  }
}
