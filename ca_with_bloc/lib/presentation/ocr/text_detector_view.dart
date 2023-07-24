import 'dart:io';

import 'package:auto_route/annotations.dart';
import 'package:ca_with_bloc/presentation/ocr/detector_helper.dart';
import 'package:ca_with_bloc/presentation/ocr/painter/text_recognizer_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'detector_view.dart';

@RoutePage()
class TextRecognizerView extends StatefulWidget {
  @override
  State<TextRecognizerView> createState() => _TextRecognizerViewState();
}

class _TextRecognizerViewState extends State<TextRecognizerView> {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return DetectorView(
        title: 'Text Detector',
        customPaint: _customPaint,
        isPause: _isBusy,
        text: _text,
        onImage: _processImage,
        initialCameraLensDirection: _cameraLensDirection,
        onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
      );
    }
    return DetectorView(
      title: 'Text Detector',
      customPaint: _customPaint,
      isPause: _isBusy,
      text: _text,
      onImage: _processImageShowBottomSheet,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage, dynamic boxView) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _text = '';
    });
    final recognizedText = await _textRecognizer.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = TextRecognizerPainter(
          recognizedText,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
          boxView);
      _customPaint = CustomPaint(painter: painter);
    } else {
      _text = 'Recognized text:\n\n${recognizedText.text}';
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    if (mounted) {
      _isBusy = false;
      setState(() {});
    }
  }

  Future<void> _processImageShowBottomSheet(
      InputImage inputImage, dynamic boxView) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _text = '';
    });
    final recognizedText = await _textRecognizer.processImage(inputImage);
    // String result = Platform.isAndroid
    //     ? DetectorHelper.checkAllBlock(recognizedText)
    //     : DetectorHelper.checkInSideBlock(recognizedText, boxView,
    //         isVertical: false);
    String result = DetectorHelper.checkInSideBlock(recognizedText, boxView,
        isVertical: false);
    if (result.isNotEmpty) {
      _showBottomSheet(context, result);
    } else {
      if (mounted) {
        _isBusy = false;
        setState(() {});
      }
    }
    // await Future.delayed(Duration(seconds: 1));
  }

  void _showBottomSheet(BuildContext context, String text) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 200,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 6.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            // Custom content for the bottom sheet
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text.substring(0, 4),
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  text.substring(4, 10),
                  style: TextStyle(fontSize: 24, color: Colors.green),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16), bottom: Radius.circular(16)),
                  ),
                  child: Text(
                    text.substring(10, 11),
                    style: TextStyle(fontSize: 24, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      if (mounted) {
        _isBusy = false;
        setState(() {});
      }
    });
  }
}
