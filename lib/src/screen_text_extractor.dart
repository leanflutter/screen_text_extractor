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

  Future<ExtractedData> extract([
    ExtractMode mode = ExtractMode.screenSelection,
  ]) async {
    ExtractedData? extractedData;
    if (mode == ExtractMode.clipboard) {
      ClipboardData? clipboardData =
          await Clipboard.getData(Clipboard.kTextPlain);
      extractedData = ExtractedData(
        text: clipboardData?.text,
      );
    } else if (mode == ExtractMode.screenCapture) {
      final Map<dynamic, dynamic> resultData =
          await _channel.invokeMethod('extractFromScreenCapture');
      extractedData =
          ExtractedData.fromJson(Map<String, dynamic>.from(resultData));
    } else if (mode == ExtractMode.screenSelection) {
      final Map<dynamic, dynamic> resultData =
          await _channel.invokeMethod('extractFromScreenSelection');
      extractedData =
          ExtractedData.fromJson(Map<String, dynamic>.from(resultData));
    }

    return extractedData!;
  }
}
