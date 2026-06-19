import 'dart:math';
import 'package:flutter/material.dart';

//draws face bounding box and oval guide on camera preview
class FaceOverlayPainter extends CustomPainter {
  final Rect? faceBoundingBox;
  final Size? imageSize;
  final bool poseMatches;
  final bool isFrontCamera;

  FaceOverlayPainter({
    this.faceBoundingBox,
    this.imageSize,
    this.poseMatches = false,
    this.isFrontCamera = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawOvalGuide(canvas, size);
    if (faceBoundingBox != null && imageSize != null) {
      _drawFaceBox(canvas, size);
    }
  }

  void _drawOvalGuide(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    //centered oval guide
    final centerX = size.width / 2;
    final centerY = size.height * 0.38;
    final ovalWidth = size.width * 0.55;
    final ovalHeight = ovalWidth * 1.35;

    //draw dashed oval
    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: ovalWidth,
      height: ovalHeight,
    );
    final path = Path()..addOval(rect);
    _drawDashedPath(canvas, path, paint);
  }

  void _drawFaceBox(Canvas canvas, Size size) {
    final scaledRect = _scaleRect(faceBoundingBox!, size);

    final color = poseMatches ? Colors.green : Colors.orange;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(scaledRect, const Radius.circular(8));
    canvas.drawRRect(rrect, paint);
  }

  Rect _scaleRect(Rect box, Size canvasSize) {
    if (imageSize == null) return Rect.zero;

    //camera image is typically rotated 90deg, so width/height are swapped
    final scaleX = canvasSize.width / imageSize!.height;
    final scaleY = canvasSize.height / imageSize!.width;

    double left;
    if (isFrontCamera) {
      //mirror horizontally for front camera
      left = canvasSize.width - (box.right * scaleX);
    } else {
      left = box.left * scaleX;
    }

    return Rect.fromLTWH(
      left,
      box.top * scaleY,
      box.width * scaleX,
      box.height * scaleY,
    );
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = min(distance + 8, metric.length);
        final extractPath = metric.extractPath(distance, end);
        canvas.drawPath(extractPath, paint);
        distance += 16;
      }
    }
  }

  @override
  bool shouldRepaint(FaceOverlayPainter oldDelegate) {
    return oldDelegate.faceBoundingBox != faceBoundingBox ||
        oldDelegate.poseMatches != poseMatches ||
        oldDelegate.imageSize != imageSize;
  }
}
