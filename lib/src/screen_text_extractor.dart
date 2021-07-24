import 'dart:async';

import 'package:flutter/services.dart';

import './extracted_result.dart';

enum ExtractMode {
  clipboard,
  screenshot,
  selection,
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

  Future<ExtractedResult> extract([
    ExtractMode mode = ExtractMode.selection,
  ]) async {
    ExtractedResult? extractedResult;
    if (mode == ExtractMode.clipboard) {
      ClipboardData? clipboardData =
          await Clipboard.getData(Clipboard.kTextPlain);
      extractedResult = ExtractedResult(
        text: clipboardData?.text,
      );
    } else if (mode == ExtractMode.selection) {
      final Map<dynamic, dynamic> resultData =
          await _channel.invokeMethod('extractFromSelection');
      extractedResult =
          ExtractedResult.fromJson(Map<String, dynamic>.from(resultData));
    }

    return extractedResult!;
  }
}
