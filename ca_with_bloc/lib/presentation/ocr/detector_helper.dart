import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:math';

class DetectorHelper {
  static bool isPointWithinBoxView(List<Offset> listOffset, Rect boxView) {
    for (var off in listOffset) {
      if (boxView.contains(off)) {
        return true;
      }
    }
    return false;
  }
  static bool isPointAllWithinBoxView(List<Offset> listOffset, Rect boxView) {
    for (var off in listOffset) {
      if (!boxView.contains(off)) {
        return false;
      }
    }
    return true;
  }
  static showLog(String logStr, {bool showLog = false}) {
    if (showLog) {
      print(logStr);
    }
  }

  static String checkInSideBlock(RecognizedText recognizedText, Rect boxView,
      {bool isVertical = false, bool isShowLog = true}) {
    if (isVertical) {
      return _checkInSideBlockVertical(recognizedText, boxView,
          isShowLog: isShowLog);
    } else {
      return _checkInSideBlock(recognizedText, boxView, isShowLog: isShowLog);
    }
  }

  static String _checkInSideBlock(RecognizedText recognizedText, Rect boxView,
      {bool isShowLog = true}) {
    List<TextBlock> blocksInside = recognizedText.blocks
        .map((bl) {
          List<Offset> offSets = bl.cornerPoints
              .map((e) => Offset(e.x.toDouble(), e.y.toDouble()))
              .toList();
          return isPointWithinBoxView(offSets, boxView) ? bl : null;
        })
        .whereType<TextBlock>()
        .toList();

    String blocksInsideString = '';
    for (var block in blocksInside) {
      blocksInsideString += block.text;
    }

    showLog("recognizedText match1203 blocksInsideString" + blocksInsideString,
        showLog: isShowLog);
    // RegExp regExp = new RegExp(r'[A-Z]{4}\s*[0-9]{6}\s*[0-9]{1}');
    RegExp regExp = new RegExp(r'[A-Z]{3}[UJZ]{1}\s*[0-9]{6}\s*[0-9]{1}');
    Iterable<RegExpMatch> matches = regExp.allMatches(blocksInsideString);
    for (RegExpMatch match in matches) {
      String containerNumber =
          blocksInsideString.substring(match.start, match.end);
      String formattedContainerNumber =
          containerNumber.replaceAll(RegExp(r'\s|-'), '');
      if (regExp.hasMatch(formattedContainerNumber)) {
        if (isValidCheckDigit(formattedContainerNumber)) {
          return formattedContainerNumber;
        }
      }
    }
    return "";
  }

  static String _checkInSideBlockVertical(
      RecognizedText recognizedText, Rect boxView,
      {bool isShowLog = true}) {
    String text = recognizedText.text.replaceAll("\n", " ");
    // showLog("_checkInSideBlockVertical recognizedText $text",
    //     showLog: isShowLog);
    List<TextBlock> blocksInside = recognizedText.blocks
        .map((bl) {
          List<Offset> offSets = bl.cornerPoints
              .map((e) => Offset(e.x.toDouble(), e.y.toDouble()))
              .toList();
          return isPointWithinBoxView(offSets, boxView) ? bl : null;
        })
        .whereType<TextBlock>()
        .toList();
    List<TextLine> lines= [];
    for (var block in blocksInside){
      List<TextLine> linesInside = block.lines
          .map((line) {
        List<Offset> offSets = line.cornerPoints
            .map((e) => Offset(e.x.toDouble(), e.y.toDouble()))
            .toList();
        return isPointWithinBoxView(offSets, boxView) ? line : null;
      })
          .whereType<TextLine>()
          .toList();
      lines.addAll(linesInside);
    }
    // showLog("_checkInSideBlockVertical blocksInsideString" + blocksInside.toString(), showLog: isShowLog);
    String blocksInsideString = '';
    for (var block in lines) {
      blocksInsideString += "\n ${block.text}";
    }

    showLog("_checkInSideBlockVertical blocksInsideString: " + blocksInsideString,
        showLog: isShowLog);
    if (blocksInside.length < 11) return "";
    // RegExp regExp = new RegExp(r'[A-Z]{4}\s*[0-9]{6}\s*[0-9]{1}');
    RegExp regExp = new RegExp(r'[A-Z]{3}[UJZ]{1}\s*[0-9]{6}\s*[0-9]{1}');
    Iterable<RegExpMatch> matches = regExp.allMatches(blocksInsideString);
    for (RegExpMatch match in matches) {
      String containerNumber =
          blocksInsideString.substring(match.start, match.end);
      String formattedContainerNumber =
          containerNumber.replaceAll(RegExp(r'\s|-'), '');
      if (regExp.hasMatch(formattedContainerNumber)) {
        if (isValidCheckDigit(formattedContainerNumber)) {
          return formattedContainerNumber;
        }
      }
    }
    return "";
  }

  static String checkAllBlock(RecognizedText recognizedText,
      {bool isShowLog = false}) {
    RegExp regExp = new RegExp(r'[A-Z]{3}[UJZ]{1}\s*[0-9]{6}\s*[0-9]{1}');
    Iterable<RegExpMatch> matches = regExp.allMatches(recognizedText.text);
    for (RegExpMatch match in matches) {
      String containerNumber =
          recognizedText.text.substring(match.start, match.end);
      String formattedContainerNumber =
          containerNumber.replaceAll(RegExp(r'\s|-'), '');
      if (regExp.hasMatch(formattedContainerNumber)) {
        if (isValidCheckDigit(formattedContainerNumber)) {
          return formattedContainerNumber;
        }
      }
    }
    return "";
  }

  static bool isValidCheckDigit(String containerNumber) {
    Map<String, int> letterValues = {
      'A': 10,
      'B': 12,
      'C': 13,
      'D': 14,
      'E': 15,
      'F': 16,
      'G': 17,
      'H': 18,
      'I': 19,
      'J': 20,
      'K': 21,
      'L': 23,
      'M': 24,
      'N': 25,
      'O': 26,
      'P': 27,
      'Q': 28,
      'R': 29,
      'S': 30,
      'T': 31,
      'U': 32,
      'V': 34,
      'W': 35,
      'X': 36,
      'Y': 37,
      'Z': 38,
      '0': 0,
      '1': 1,
      '2': 2,
      '3': 3,
      '4': 4,
      '5': 5,
      '6': 6,
      '7': 7,
      '8': 8,
      '9': 9
    };

    int sum = 0;
    for (int i = 0; i < containerNumber.length - 1; i++) {
      int value = letterValues[containerNumber[i]]!;
      var a = containerNumber.length - i;
      sum += value * pow(2, containerNumber.length - a).toInt();
    }
    int checkDigit = sum % 11;
    if (checkDigit == 10) {
      checkDigit = 0;
    }
    int containerDigit = int.parse(containerNumber[containerNumber.length - 1]);
    print("isValidCheckDigit containerDigit:$containerDigit");
    print("isValidCheckDigit calculate digit:$checkDigit");
    print("isValidCheckDigit calculate sum:$sum");
    return checkDigit == containerDigit;
  }
}
