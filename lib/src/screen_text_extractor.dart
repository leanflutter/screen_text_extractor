import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'extracted_data.dart';

enum ExtractMode {
  clipboard,
  screenCapture,
  screenSelection,
}

class ScreenTextExtractor {
  ScreenTextExtractor._();

  /// The shared instance of [ScreenTextExtractor].
  static final ScreenTextExtractor instance = ScreenTextExtractor._();

  MethodChannel _channel = const MethodChannel('screen_text_extractor');

  Future<bool> isAllowedScreenCaptureAccess() async {
    if (kIsWeb) return true;
    if (Platform.isLinux) return true;
    if (Platform.isWindows) return true;
    return await _channel.invokeMethod('isAllowedScreenCaptureAccess');
  }

  Future<void> requestScreenCaptureAccess({
    bool onlyOpenPrefPane = false,
  }) async {
    if (Platform.isLinux) return;
    if (Platform.isWindows) return;
    final Map<String, dynamic> arguments = {
      'onlyOpenPrefPane': onlyOpenPrefPane,
    };
    await _channel.invokeMethod('requestScreenCaptureAccess', arguments);
  }

  Future<bool> isAllowedScreenSelectionAccess() async {
    if (kIsWeb) return true;
    if (Platform.isLinux) return true;
    if (Platform.isWindows) return true;
    return await _channel.invokeMethod('isAllowedScreenSelectionAccess');
  }

  Future<void> requestScreenSelectionAccess({
    bool onlyOpenPrefPane = false,
  }) async {
    if (Platform.isLinux) return;
    if (Platform.isWindows) return;
    final Map<String, dynamic> arguments = {
      'onlyOpenPrefPane': onlyOpenPrefPane,
    };
    await _channel.invokeMethod('requestScreenSelectionAccess', arguments);
  }

  Future<bool> simulateCtrlCKeyPress() async {
    return await _channel.invokeMethod('simulateCtrlCKeyPress', {});
  }

  Future<ExtractedData> extractFromClipboard() async {
    ClipboardData? d = await Clipboard.getData(Clipboard.kTextPlain);
    return ExtractedData(text: d?.text ?? '');
  }

  Future<ExtractedData> extractFromScreenCapture({
    String? imagePath,
  }) async {
    Map<String, dynamic> arguments = {};
    if (!kIsWeb) {
      if (imagePath == null) throw ArgumentError.notNull('imagePath');

      File imageFile = File(imagePath);
      if (!imageFile.parent.existsSync()) {
        imageFile.parent.create(recursive: true);
      }
      arguments = {
        'imagePath': imagePath,
      };
    }
    final Map<dynamic, dynamic> resultData = await _channel.invokeMethod(
      'extractFromScreenCapture',
      arguments,
    );

    ExtractedData extractedData = ExtractedData.fromJson(
      Map<String, dynamic>.from(resultData),
    );
    if (extractedData.text != null) {
      extractedData.text = extractedData.text!.trim();
    }
    if (extractedData.base64Image == null) {
      File imageFile = File(imagePath!);
      if (imageFile.existsSync()) {
        Uint8List imageBytes = imageFile.readAsBytesSync();
        var decodedImage = await decodeImageFromList(imageBytes);
        extractedData.imageWidth = decodedImage.width.toDouble();
        extractedData.imageHeight = decodedImage.height.toDouble();
        extractedData.base64Image = base64Encode(imageBytes);
      }
    }
    return extractedData;
  }

  Future<ExtractedData> extractFromScreenSelection({
    bool useAccessibilityAPIFirst = false,
  }) async {
    ExtractedData extractedData = ExtractedData(text: '');
    if (Platform.isWindows) {
      // 通过模拟按下 Ctrl+C 快捷键以达到取词的目的。
      await simulateCtrlCKeyPress();
      await Future.delayed(Duration(milliseconds: 300));
      return extractFromClipboard();
    } else {
      final Map<dynamic, dynamic> resultData = await _channel.invokeMethod(
        'extractFromScreenSelection',
        {
          'useAccessibilityAPIFirst': useAccessibilityAPIFirst,
        },
      );
      extractedData = ExtractedData.fromJson(
        Map<String, dynamic>.from(resultData),
      );
    }
    if (extractedData.text != null)
      extractedData.text = extractedData.text!.trim();
    return extractedData;
  }
}
