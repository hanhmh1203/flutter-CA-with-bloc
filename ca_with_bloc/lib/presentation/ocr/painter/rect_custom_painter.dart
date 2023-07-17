import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ScanRectPainter extends CustomPainter {
  final Rect scanRect;
  static final double scanRectWidthRatio = 0.6;
  static final double scanRectHeightRatio = 0.3;


  ScanRectPainter({required this.scanRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(scanRect, paint);
  }

  @override
  bool shouldRepaint(ScanRectPainter oldDelegate) {
    return scanRect != oldDelegate.scanRect;
  }
  static Rect calculateScanRect(BuildContext context) {
    // final cameraSize = controller.value.previewSize!;
    // print("hanhmh1203calculateScanRect previewSize: height:${cameraSize.height}, width:${cameraSize.width}");
    // final double rectangleWidth = cameraSize.height.toDouble()/2;
    // final double rectangleHeight = 200;
    // final double left = 0;
    // final double top = (cameraSize.height.toDouble() - rectangleHeight) /4;
    // print("hanhmh1203calculateScanRect $left, $top, $rectangleWidth, $rectangleHeight");
    // return Rect.fromLTWH(left, top, rectangleWidth, rectangleHeight);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
  return Rect.fromLTWH(0, 0, width, height);
  }
}
// 1280.0, 720.0 256.0 252.0 768.0 216.0