import 'dart:async';

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

  Future<void> requestEnable() async {
    await _channel.invokeMethod('requestEnable');
  }

  Future<bool> isEnabled() async {
    return await _channel.invokeMethod('isEnabled');
  }

  Future<ExtractedData> extract({
    ExtractMode mode = ExtractMode.screenSelection,
    String? imagePath,
  }) async {
    ExtractedData? extractedData;
    if (mode == ExtractMode.clipboard) {
      extractedData = await extractFromClipboard();
    } else if (mode == ExtractMode.screenCapture) {
      extractedData = await extractFromScreenCapture(imagePath!);
    } else if (mode == ExtractMode.screenSelection) {
      extractedData = await extractFromScreenSelection();
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

  Future<ExtractedData> extractFromScreenCapture(String imagePath) async {
    final Map<String, dynamic> arguments = {
      'imagePath': imagePath,
    };
    final Map<dynamic, dynamic> resultData =
        await _channel.invokeMethod('extractFromScreenCapture', arguments);
    return ExtractedData.fromJson(Map<String, dynamic>.from(resultData));
  }

  Future<ExtractedData> extractFromScreenSelection() async {
    final Map<dynamic, dynamic> resultData =
        await _channel.invokeMethod('extractFromScreenSelection');
    return ExtractedData.fromJson(Map<String, dynamic>.from(resultData));
  }
}
