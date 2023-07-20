import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

double translateX(
  double x,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return x *
          canvasSize.width /
          (Platform.isIOS ? imageSize.width : imageSize.height);
    case InputImageRotation.rotation270deg:
      return canvasSize.width -
          x *
              canvasSize.width /
              (Platform.isIOS ? imageSize.width : imageSize.height);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      switch (cameraLensDirection) {
        case CameraLensDirection.back:
          return x * canvasSize.width / imageSize.width;
        default:
          return canvasSize.width - x * canvasSize.width / imageSize.width;
      }
  }
}

double getRatioX(
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return (Platform.isIOS ? imageSize.width : imageSize.height) /
          canvasSize.width;
    case InputImageRotation.rotation270deg:
      return canvasSize.width -
          (Platform.isIOS ? imageSize.width : imageSize.height) /
              canvasSize.width;
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      return imageSize.width / canvasSize.width;
  }
}

double getRatioY(Size canvasSize, Size imageSize, InputImageRotation rotation) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return (Platform.isIOS ? imageSize.height : imageSize.width) /
          canvasSize.height;
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      return imageSize.height / canvasSize.height;
  }
}

double translateY(
  double y,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return y *
          canvasSize.height /
          (Platform.isIOS ? imageSize.height : imageSize.width);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      return y * canvasSize.height / imageSize.height;
  }
}

double translateX2(double x, Size boxView, Size screenSize) {
  return x *
      boxView.width /
      (Platform.isIOS ? screenSize.width : screenSize.height);
}

double translateY2(double y, Size boxView, Size screenSize) {
  return y *
      boxView.height /
      (Platform.isIOS ? screenSize.height : screenSize.width);
}
