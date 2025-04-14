import 'package:flutter/material.dart';

/// A custom painter that draws a subtle wave shape at the top.
class WavePainter extends CustomPainter {
  const WavePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.3);
    final path =
        Path()
          ..lineTo(0, size.height * 0.8)
          ..quadraticBezierTo(size.width * 0.25, size.height, size.width * 0.5, size.height * 0.8)
          ..quadraticBezierTo(size.width * 0.75, size.height * 0.6, size.width, size.height * 0.8)
          ..lineTo(size.width, 0)
          ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}