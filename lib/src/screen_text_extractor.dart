import 'dart:async';
import 'dart:io';

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
    if (Platform.isLinux) return true;
    return await _channel.invokeMethod('isAllowedScreenCaptureAccess');
  }

  Future<void> requestScreenCaptureAccess() async {
    if (Platform.isLinux) return;
    await _channel.invokeMethod('requestScreenCaptureAccess');
  }

  Future<bool> isAllowedScreenSelectionAccess() async {
    if (Platform.isLinux) return true;
    return await _channel.invokeMethod('isAllowedScreenSelectionAccess');
  }

  Future<void> requestScreenSelectionAccess() async {
    if (Platform.isLinux) return;
    await _channel.invokeMethod('requestScreenSelectionAccess');
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
    if (imagePath == null) throw ArgumentError.notNull('imagePath');

    File imageFile = File(imagePath);
    if (!imageFile.parent.existsSync()) {
      imageFile.parent.create(recursive: true);
    }
    final Map<String, dynamic> arguments = {
      'imagePath': imagePath,
    };
    final Map<dynamic, dynamic> resultData = await _channel.invokeMethod(
      'extractFromScreenCapture',
      arguments,
    );
    return ExtractedData.fromJson(Map<String, dynamic>.from(resultData));
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
