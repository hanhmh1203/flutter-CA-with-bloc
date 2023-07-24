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
  Size previewCameraSize,
  Size boxViewCameraSize,
  InputImageRotation rotation,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      print("hanhmh1203 getRatioX 1");
      // return (Platform.isIOS ? previewCameraSize.height : previewCameraSize.width) /
      //     boxViewCameraSize.width;
      return previewCameraSize.height / boxViewCameraSize.width;
    case InputImageRotation.rotation270deg:
      print("hanhmh1203 getRatioX 2");
      return boxViewCameraSize.width -
          (Platform.isIOS
                  ? previewCameraSize.width
                  : previewCameraSize.height) /
              boxViewCameraSize.width;
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      print("hanhmh1203 getRatioX 3");
      return previewCameraSize.width / boxViewCameraSize.width;
  }
}

double getRatioY(Size previewCameraSize, Size boxViewCameraSize,
    InputImageRotation rotation) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return previewCameraSize.width / boxViewCameraSize.height;
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      return previewCameraSize.height / boxViewCameraSize.height;
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
