import 'dart:io';
import 'dart:ui';
import 'package:ca_with_bloc/presentation/ocr/painter/coordinates_translator.dart';
import 'package:ca_with_bloc/presentation/ocr/painter/rect_custom_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
part 'android.dart';
part 'ios.dart';
class CameraView extends StatefulWidget {
  CameraView({Key? key,
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
    return Scaffold(body: _liveFeedBody());
  }

  Widget _liveFeedBody() {
    var width = MediaQuery
        .of(context)
        .size
        .width;
    var height = MediaQuery
        .of(context)
        .size
        .height;
    if (_cameras.isEmpty) return Container();
    if (_controller == null) return Container();
    if (_controller?.value.isInitialized == false) return Container();
    // correct for IOS
    double aspectRatio = _controller!.value.aspectRatio;
    double cameraViewTop = paddingTop;
    double cameraViewLeft = paddingLeft;
    double cameraViewWidth = width - paddingLeft - paddingRight;
    double cameraViewHeight = width * aspectRatio;

    // set boxView size
    // horizon view
    double boxViewWidth = cameraViewWidth - cameraViewWidth / 4;
    double boxViewHeight = cameraViewHeight / 4;

    // vertical view
    // double boxViewWidth = (cameraViewWidth - cameraViewWidth / 4)/8;
    // double boxViewHeight = cameraViewHeight / 2;
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
                key: previewKey,
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
                        height: cameraViewHeight,
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
                    border: Border.all(color: Colors.yellow, width: 4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  // Other child widgets here
                ),
              ),
            ],
          ),
          _backButton(),
          // _switchLiveCameraToggle(),
          // _detectionViewModeToggle(),
          _zoomControl(),
          // _exposureControl(),
        ],
      ),
    );
  }

  Rect? _boxRect;

  Rect convertRectToRectToCamera() {
    Size previewSize = _controller!.value.previewSize!;
    final RenderBox box =
    boxKey.currentContext?.findRenderObject() as RenderBox;
    final fromRect = box.localToGlobal(Offset.zero) & box.size;

    final RenderBox previewCamera =
    previewKey.currentContext?.findRenderObject() as RenderBox;
    final rectCameraView =
    previewCamera.localToGlobal(Offset.zero) & previewCamera.size;

    var ratioW = previewSize.height / rectCameraView.width;
    var ratioH = previewSize.width / rectCameraView.height;

    var ratioW2 = getRatioX(previewSize, rectCameraView.size, _getRotation()!);
    var ratioH2 = getRatioY(previewSize, rectCameraView.size, _getRotation()!);

    var left = (fromRect.left - paddingLeft) * ratioW2;
    var top = (fromRect.top - paddingTop) * ratioH2;
    var right = left + (fromRect.width * ratioW2);
    var bottom = top + (fromRect.height * ratioH2);
    final toRect = Rect.fromLTRB(left, top, right, bottom);
    return toRect;
  }


  Widget _backButton() =>
      Positioned(
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

  Widget _detectionViewModeToggle() =>
      Positioned(
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

  Widget _switchLiveCameraToggle() =>
      Positioned(
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

  Widget _zoomControl() =>
      Positioned(
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

  Widget _exposureControl() =>
      Positioned(
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
      if (_controller!.value.isPreviewPaused && !widget.isPause) {
        _controller?.resumePreview();
      }
      if (!_controller!.value.isPreviewPaused && widget.isPause) {
        _controller?.pausePreview();
      }
      setState(() {
        if (Platform.isAndroid) {
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


  Future<void> _processCameraImage(CameraImage image) async {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    if (Platform.isAndroid) {
      _boxRect ??= convertRectToRectToCamera();
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
