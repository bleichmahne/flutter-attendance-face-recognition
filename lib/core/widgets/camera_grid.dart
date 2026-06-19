import 'package:flutter/material.dart';

class CameraGrid extends StatelessWidget {
  final int crossAxisCount;
  final Color color;
  final double strokeWidth;

  const CameraGrid({
    super.key,
    this.crossAxisCount = 3,
    this.color = Colors.white,
    this.strokeWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPainter(
        crossAxisCount: crossAxisCount,
        color: color,
        strokeWidth: strokeWidth,
      ),
      child: Container(),
    );
  }
}

class GridPainter extends CustomPainter {
  final int crossAxisCount;
  final Color color;
  final double strokeWidth;

  GridPainter({
    required this.crossAxisCount,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final stepX = size.width / crossAxisCount;
    final stepY = size.height / crossAxisCount;

    for (int i = 1; i < crossAxisCount; i++) {
      final x = stepX * i;
      final y = stepY * i;

      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

