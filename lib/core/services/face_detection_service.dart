import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

//on-device face detection via google ml kit
class FaceDetectionService {
  late final FaceDetector _detector;

  FaceDetectionService() {
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableClassification: false,
        enableTracking: true,
        enableLandmarks: false,
        enableContours: false,
      ),
    );
  }

  //process a camera frame and return detected faces
  Future<List<Face>> detectFromCameraImage(
    CameraImage image,
    InputImageRotation rotation,
    InputImageFormat format,
  ) async {
    final plane = image.planes.first;
    final inputImage = InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
    return _detector.processImage(inputImage);
  }

  Future<void> dispose() async {
    await _detector.close();
  }
}
