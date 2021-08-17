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
    return await _channel.invokeMethod('isAllowedScreenCaptureAccess');
  }

  Future<void> requestScreenCaptureAccess({
    bool onlyOpenPrefPane = false,
  }) async {
    if (Platform.isLinux) return;
    final Map<String, dynamic> arguments = {
      'onlyOpenPrefPane': onlyOpenPrefPane,
    };
    await _channel.invokeMethod('requestScreenCaptureAccess', arguments);
  }

  Future<bool> isAllowedScreenSelectionAccess() async {
    if (kIsWeb) return true;
    if (Platform.isLinux) return true;
    return await _channel.invokeMethod('isAllowedScreenSelectionAccess');
  }

  Future<void> requestScreenSelectionAccess({
    bool onlyOpenPrefPane = false,
  }) async {
    if (Platform.isLinux) return;
    final Map<String, dynamic> arguments = {
      'onlyOpenPrefPane': onlyOpenPrefPane,
    };
    await _channel.invokeMethod('requestScreenSelectionAccess', arguments);
  }

  Future<ExtractedData> extract({
    ExtractMode mode = ExtractMode.screenSelection,
    String? imagePath,
    bool? simulateCopyShortcut,
  }) async {
    ExtractedData? extractedData;
    if (mode == ExtractMode.clipboard) {
      extractedData = await extractFromClipboard();
    } else if (mode == ExtractMode.screenCapture) {
      extractedData = await extractFromScreenCapture(imagePath);
    } else if (mode == ExtractMode.screenSelection) {
      extractedData = await extractFromScreenSelection(simulateCopyShortcut);
    }
    return extractedData!;
  }

  Future<ExtractedData> extractFromClipboard() async {
    ClipboardData? clipboardData =
        await Clipboard.getData(Clipboard.kTextPlain);
    return ExtractedData(
      text: clipboardData?.text,
    );
  }

  Future<ExtractedData> extractFromScreenCapture(
    String? imagePath,
  ) async {
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

    ExtractedData extractedData =
        ExtractedData.fromJson(Map<String, dynamic>.from(resultData));
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

  Future<ExtractedData> extractFromScreenSelection(
    bool? simulateCopyShortcut,
  ) async {
    final Map<String, dynamic> arguments = {
      'simulateCopyShortcut': simulateCopyShortcut ?? false,
    };
    final Map<dynamic, dynamic> resultData = await _channel.invokeMethod(
      'extractFromScreenSelection',
      arguments,
    );
    return ExtractedData.fromJson(Map<String, dynamic>.from(resultData));
  }
}
