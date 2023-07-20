import 'dart:io';
import 'dart:ui';
import 'package:ca_with_bloc/presentation/ocr/painter/coordinates_translator.dart';
import 'package:ca_with_bloc/presentation/ocr/painter/rect_custom_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';

class CameraView extends StatefulWidget {
  CameraView(
      {Key? key,
      required this.customPaint,
      required this.onImage,
      required this.isPause,
      this.onCameraFeedReady,
      this.onDetectorViewModeChanged,
      this.onCameraLensDirectionChanged,
      this.initialCameraLensDirection = CameraLensDirection.back})
      : super(key: key);
  final bool isPause;
  final CustomPaint? customPaint;
  final Function(InputImage inputImage, dynamic customPainter) onImage;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  static List<CameraDescription> _cameras = [];
  final paddingTop = 0.0;
  final paddingLeft = 0.0;
  final paddingRight = 0.0;
  CameraController? _controller;
  int _cameraIndex = -1;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  bool _changingCameraLens = false;
  CustomPainter? _customPainter;

  @override
  void initState() {
    super.initState();

    _initialize();

  }

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }

    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  final boxKey = GlobalKey();
  final previewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (widget.isPause) {
      _controller?.pausePreview();
    } else {
      _controller?.resumePreview();
    }
    if (Platform.isAndroid) {
      return Scaffold(body: _liveFeedBodyAndroid());
    }
    return Scaffold(body: _liveFeedBody());
  }

  Widget _liveFeedBody() {
    var width = MediaQuery.of(context).size.width;
    if (_cameras.isEmpty) return Container();
    if (_controller == null) return Container();
    if (_controller?.value.isInitialized == false) return Container();
    // correct for IOS
    double aspectRatio = _controller!.value.aspectRatio;
    double cameraViewTop = paddingTop;
    double cameraViewLeft = paddingLeft;
    double cameraViewWidth = width - paddingLeft - paddingRight;
    double cameraViewHeight = width; //* aspectRatio;

    // set boxView size
    double boxViewWidth = cameraViewWidth - cameraViewWidth / 4;
    double boxViewHeight = cameraViewHeight / 4;
    double boxViewTop = (cameraViewHeight - boxViewHeight) / 2 + paddingTop;
    double boxViewLeft = (cameraViewWidth - boxViewWidth) / 2 + paddingLeft;

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _changingCameraLens
              ? Center(
                  child: const Text('Changing camera lens'),
                )
              : Stack(
                  children: [
                    Positioned(
                      top: cameraViewTop,
                      left: cameraViewLeft,
                      width: cameraViewWidth,
                      height: cameraViewHeight,
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: cameraViewWidth,
                              height: cameraViewWidth * aspectRatio,
                              // calculate height based on camera aspect ratio
                              child: CameraPreview(
                                _controller!,
                                child: widget.customPaint,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      key: boxKey,
                      top: boxViewTop,
                      left: boxViewLeft,
                      width: boxViewWidth,
                      height: boxViewHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   child: CustomPaint(
                    //     painter: _customPainter,
                    //   ),
                    // )
                  ],
                ),
          _backButton(),
          _switchLiveCameraToggle(),
          _detectionViewModeToggle(),
          _zoomControl(),
          _exposureControl(),
        ],
      ),
    );
  }

  late double cameraViewWidth;
  late double cameraViewHeight;
  late double cameraPreviewWidth;
  late double cameraPreviewHeight;

  late double boxViewWidth;
  late double boxViewHeight;
  late double boxViewTop;
  late double boxViewLeft;

  Widget _liveFeedBodyAndroid() {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    if (_cameras.isEmpty) return Container();
    if (_controller == null) return Container();
    if (_controller?.value.isInitialized == false) return Container();
    // correct for IOS
    double aspectRatio = _controller!.value.aspectRatio;
    print(
        "hanhmh1203 _liveFeedBodyAndroid scrren size width:$width, height: ${height}");
    print("hanhmh1203 aspectRatio:$aspectRatio");
    print("hanhmh1203 camera width ${_controller!.value.previewSize!.width}");
    print("hanhmh1203 camera height ${_controller!.value.previewSize!.height}");
    double cameraViewTop = paddingTop;
    double cameraViewLeft = paddingLeft;
    // double cameraViewWidth = width - paddingLeft - paddingRight;
    // double cameraViewHeight = width * aspectRatio;
    cameraViewWidth = _controller!.value.previewSize!.height;
    cameraViewHeight = _controller!.value.previewSize!.width;
    cameraPreviewWidth = cameraViewWidth;
    cameraPreviewHeight = cameraViewHeight;

    // set boxView size
    boxViewWidth = cameraViewWidth - cameraViewWidth / 2;
    boxViewHeight = cameraViewHeight / 4;
    boxViewTop = (cameraViewHeight - boxViewHeight) / 2 + paddingTop;
    boxViewLeft = (cameraViewWidth - boxViewWidth) / 2 + paddingLeft;

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _changingCameraLens
              ? Center(
                  child: const Text('Changing camera lens'),
                )
              : Stack(
                  children: [
                    Positioned(
                      top: cameraViewTop,
                      left: cameraViewLeft,
                      width: cameraViewWidth,
                      height: cameraViewHeight,
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              key: previewKey,
                              width: cameraPreviewWidth,
                              height: cameraPreviewHeight,
                              // calculate height based on camera aspect ratio
                              child: CameraPreview(
                                _controller!,
                                child: widget.customPaint,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      key: boxKey,
                      top: boxViewTop,
                      left: boxViewLeft,
                      width: boxViewWidth,
                      height: boxViewHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   child: CustomPaint(
                    //     painter: _customPainter,
                    //   ),
                    // )
                  ],
                ),
          _backButton(),
          _switchLiveCameraToggle(),
          _detectionViewModeToggle(),
          _zoomControl(),
          _exposureControl(),
        ],
      ),
    );
  }
  Rect? _boxRect;
  Rect convertRectToRectToCamera() {
    // padding top, left, right, bottom
    // return fromRect;
    final RenderBox box =
    boxKey.currentContext?.findRenderObject() as RenderBox;
    final fromRect = box.localToGlobal(Offset.zero) & box.size;
    return Rect.fromLTRB(fromRect.left - paddingLeft, fromRect.top - paddingTop,
        fromRect.right, fromRect.bottom);
  }

  Rect convertRectToRectToCameraAndroid() {
    final RenderBox box =
    boxKey.currentContext?.findRenderObject() as RenderBox;
    final fromRect = box.localToGlobal(Offset.zero) & box.size;

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final croppedRect = box.localToGlobal(Offset.zero) & box.size;

    final RenderBox boxPreview =
        previewKey.currentContext?.findRenderObject() as RenderBox;
    final boundRect = boxPreview.localToGlobal(Offset.zero) & boxPreview.size;
    Size mediaImage = _controller!.value.previewSize!;

    double imageHeight = 0.0;
    double imageWidth = 0.0;
    InputImageRotation? rotation = _getRotation();
    switch (rotation) {
      case InputImageRotation.rotation90deg:
      case InputImageRotation.rotation270deg:
        imageHeight = mediaImage.width;
        imageWidth = mediaImage.height;
        break;
      default:
        imageHeight = mediaImage.height;
        imageWidth = mediaImage.width;
        // Code to handle other rotation values or conditions
        break;
    }
    var wRatio = boundRect.width * 1 / imageWidth;
    var hRatio = boundRect.height * 1 / imageHeight;
    var newWidth = croppedRect.width / wRatio;
    var newHeight = croppedRect.height / hRatio;
    var newLeft = (croppedRect.left - boundRect.left) / wRatio;
    var newTop = (croppedRect.top - boundRect.top) / hRatio;
    Rect result = Rect.fromLTWH(
        newLeft, newTop, (newLeft + newWidth), (newTop + newHeight));
    print(
        "hanhmh1203 convertRectToRectToCameraAndroid \nboxResult:$result ${result.size}");
    return result;
    //
    // // padding top, left, right, bottom
    // // return fromRect;
    // var width = MediaQuery.of(context).size.width;
    // var height = MediaQuery.of(context).size.height;
    // // var scaleX = height/
    // var scaleX = height / cameraPreviewWidth;
    // var scaleY = width / cameraPreviewHeight;
    //
    // // var left = scaleY * fromRect.left;
    // // var right = scaleY * fromRect.right;
    // // var top = fromRect.top * scaleX;
    // // var bottom = fromRect.bottom * scaleX;
    //
    // var left = translateX2(
    //     fromRect.bottom, fromRect.size, MediaQuery.of(context).size);
    // var right = translateX2(
    //   fromRect.top,
    //   fromRect.size,
    //   MediaQuery.of(context).size,
    // );
    // var top = translateY2(
    //   fromRect.right,
    //   fromRect.size,
    //   MediaQuery.of(context).size,
    // );
    // var bottom = translateY2(
    //   fromRect.left,
    //   fromRect.size,
    //   MediaQuery.of(context).size,
    // );
    //
    // // return Rect.fromLTRB(fromRect.right - paddingLeft, fromRect.bottom - paddingTop,
    // //     fromRect.left, fromRect.top);
    // return Rect.fromLTRB(left - paddingLeft, top - paddingTop, right, bottom);
  }

  Widget _backButton() => Positioned(
        top: 40,
        left: 8,
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: Colors.black54,
            child: Icon(
              Icons.arrow_back_ios_outlined,
              size: 20,
            ),
          ),
        ),
      );

  Widget _detectionViewModeToggle() => Positioned(
        bottom: 8,
        left: 8,
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: widget.onDetectorViewModeChanged,
            backgroundColor: Colors.black54,
            child: Icon(
              Icons.photo_library_outlined,
              size: 25,
            ),
          ),
        ),
      );

  Widget _switchLiveCameraToggle() => Positioned(
        bottom: 8,
        right: 8,
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: _switchLiveCamera,
            backgroundColor: Colors.black54,
            child: Icon(
              Platform.isIOS
                  ? Icons.flip_camera_ios_outlined
                  : Icons.flip_camera_android_outlined,
              size: 25,
            ),
          ),
        ),
      );

  Widget _zoomControl() => Positioned(
        bottom: 16,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 250,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Slider(
                    value: _currentZoomLevel,
                    min: _minAvailableZoom,
                    max: _maxAvailableZoom,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    onChanged: (value) async {
                      setState(() {
                        _currentZoomLevel = value;
                      });
                      await _controller?.setZoomLevel(value);
                    },
                  ),
                ),
                Container(
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        '${_currentZoomLevel.toStringAsFixed(1)}x',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _exposureControl() => Positioned(
        top: 40,
        right: 8,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 250,
          ),
          child: Column(children: [
            Container(
              width: 55,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    '${_currentExposureOffset.toStringAsFixed(1)}x',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              child: RotatedBox(
                quarterTurns: 3,
                child: SizedBox(
                  height: 30,
                  child: Slider(
                    value: _currentExposureOffset,
                    min: _minAvailableExposureOffset,
                    max: _maxAvailableExposureOffset,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    onChanged: (value) async {
                      setState(() {
                        _currentExposureOffset = value;
                      });
                      await _controller?.setExposureOffset(value);
                    },
                  ),
                ),
              ),
            )
          ]),
        ),
      );

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        _currentZoomLevel = value;
        _minAvailableZoom = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        _maxAvailableZoom = value;
      });
      _currentExposureOffset = 0.0;
      _controller?.getMinExposureOffset().then((value) {
        _minAvailableExposureOffset = value;
      });
      _controller?.getMaxExposureOffset().then((value) {
        _maxAvailableExposureOffset = value;
      });

      _controller?.startImageStream(_processCameraImage).then((value) {
        if (widget.onCameraFeedReady != null) {
          widget.onCameraFeedReady!();
        }
        if (widget.onCameraLensDirectionChanged != null) {
          widget.onCameraLensDirectionChanged!(camera.lensDirection);
        }
      });
      setState(() {
        print("hanhmh1203 _initialize _customPainter");
        if(Platform.isAndroid){
          _customPainter = ScanRectPainter(
            scanRect: ScanRectPainter.calculateScanRect(context),
          );
        }
      });
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  static Future<File> writeUint8ListToFile(
      String filePath, Uint8List bytes) async {
    var file = File(filePath);
    if (await file.exists()) await file.delete();
    return file.writeAsBytes(bytes);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    if (Platform.isAndroid) {
      _boxRect ??= convertRectToRectToCameraAndroid();
    } else {
      _boxRect ??= convertRectToRectToCamera();
    }
    widget.onImage(inputImage, _boxRect);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    // get camera rotation
    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;

    var rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    if (Platform.isAndroid) {
      rotation = _getRotation();
      // print('rotationCompensation: $rotationCompensation');
    }
    if (rotation == null) return null;
    // print('final rotation: $rotation');

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        // size: Size(width, height),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  InputImageRotation? _getRotation() {
    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    var rotationCompensation =
        _orientations[_controller!.value.deviceOrientation];
    if (rotationCompensation == null) return null;
    if (camera.lensDirection == CameraLensDirection.front) {
      // front-facing
      rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
    } else {
      // back-facing
      rotationCompensation =
          (sensorOrientation - rotationCompensation + 360) % 360;
    }
    return InputImageRotationValue.fromRawValue(rotationCompensation);
  }
}
