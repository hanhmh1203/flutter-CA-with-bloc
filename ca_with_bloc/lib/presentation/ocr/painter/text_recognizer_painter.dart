import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:ca_with_bloc/presentation/ocr/detector_helper.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'coordinates_translator.dart';

class TextRecognizerPainter extends CustomPainter {
  TextRecognizerPainter(this.recognizedText, this.imageSize, this.rotation,
      this.cameraLensDirection, this.boxView);

  dynamic boxView;
  final RecognizedText recognizedText;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    print("hanhmh1203, canvas size : $size");
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;
    // paint.color = Colors.yellow;
    var box = boxView as Rect;
    // _draw(element, size, canvas);
    // var boxViewConverted = _getBoxViewAfterConvert(size);
    canvas.drawRect(
      _getBoxViewAfterConvert(size),
      // Rect.fromLTRB(left, top, right, bottom),
      paint,
    );

    print("hanhmh1203 paint canvas:width ${size.width}, height:${size.height}");
    for (var block in recognizedText.blocks) {
      for (var line in block.lines) {
        // for (var element in line.elements) {
          List<Offset> offSets = line.cornerPoints
              .map((e) => Offset(e.x.toDouble(), e.y.toDouble()))
              .toList();

          if (DetectorHelper.isPointWithinBoxView(offSets, box)) {
            _draw(line, size, canvas);
          }
        // }
      }
    }
  }

  Rect _getBoxViewAfterConvert(Size canvasSize) {
    var box = boxView as Rect;
    // return box;
    var left = translateX(
      box.left,
      canvasSize,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    var top = translateY(
      box.top,
      canvasSize,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    var right = translateX(
      box.right,
      canvasSize,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    var bottom = translateY(
      box.bottom,
      canvasSize,
      imageSize,
      rotation,
      cameraLensDirection,
    );

    return Rect.fromLTRB(left, top, right, bottom);
  }

  _draw(dynamic textBlock, Size size, Canvas canvas) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.yellow;
    // paint.color = Colors.yellow;
    final Paint background = Paint()..color = Color(0x99000000);
    final ParagraphBuilder builder = ParagraphBuilder(
      ParagraphStyle(
          textAlign: TextAlign.left,
          fontSize: 16,
          textDirection: TextDirection.ltr),
    );
    builder
        .pushStyle(ui.TextStyle(color: Colors.yellow, background: background));
    builder.addText(textBlock.text);
    builder.pop();

    final left = translateX(
      textBlock.boundingBox.left,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    final top = translateY(
      textBlock.boundingBox.top,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    final right = translateX(
      textBlock.boundingBox.right,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );

    final bottom = translateY(
      textBlock.boundingBox.bottom,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    //
    // print("hanhmh1203 boxRect:")
    // canvas.drawRect(
    //   _getBoxViewAfterConvert(size),
    //   // Rect.fromLTRB(left, top, right, bottom),
    //   paint,
    // );
    final List<Offset> cornerPoints = <Offset>[];
    for (final point in textBlock.cornerPoints) {
      double x = translateX(
        point.x.toDouble(),
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      double y = translateY(
        point.y.toDouble(),
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      if (Platform.isAndroid) {
        switch (cameraLensDirection) {
          case CameraLensDirection.front:
            switch (rotation) {
              case InputImageRotation.rotation0deg:
              case InputImageRotation.rotation90deg:
                break;
              case InputImageRotation.rotation180deg:
                x = size.width - x;
                y = size.height - y;
                break;
              case InputImageRotation.rotation270deg:
                x = translateX(
                  point.y.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                );
                y = size.height -
                    translateY(
                      point.x.toDouble(),
                      size,
                      imageSize,
                      rotation,
                      cameraLensDirection,
                    );
                break;
            }
            break;
          case CameraLensDirection.back:
            switch (rotation) {
              case InputImageRotation.rotation0deg:
              case InputImageRotation.rotation270deg:
                break;
              case InputImageRotation.rotation180deg:
                x = size.width - x;
                y = size.height - y;
                break;
              case InputImageRotation.rotation90deg:
                x = size.width -
                    translateX(
                      point.y.toDouble(),
                      size,
                      imageSize,
                      rotation,
                      cameraLensDirection,
                    );
                y = translateY(
                  point.x.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                );
                break;
            }
            break;
          case CameraLensDirection.external:
            break;
        }
      }

      cornerPoints.add(Offset(x, y));
    }

    // Add the first point to close the polygon
    cornerPoints.add(cornerPoints.first);
    canvas.drawPoints(PointMode.polygon, cornerPoints, paint);

    canvas.drawParagraph(
      builder.build()
        ..layout(ParagraphConstraints(
          width: (right - left).abs(),
        )),
      Offset(
          Platform.isAndroid && cameraLensDirection == CameraLensDirection.front
              ? right
              : left,
          top),
    );
  }

  @override
  bool shouldRepaint(TextRecognizerPainter oldDelegate) {
    return oldDelegate.recognizedText.blocks.length !=
        recognizedText.blocks.length;
  }
}
