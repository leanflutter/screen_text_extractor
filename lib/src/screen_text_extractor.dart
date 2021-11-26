import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'extracted_data.dart';

enum ExtractMode {
  clipboard,
  screenSelection,
}

class ScreenTextExtractor {
  ScreenTextExtractor._();

  /// The shared instance of [ScreenTextExtractor].
  static final ScreenTextExtractor instance = ScreenTextExtractor._();

  MethodChannel _channel = const MethodChannel('screen_text_extractor');

  Future<bool> isAccessAllowed() async {
    if (!kIsWeb && Platform.isMacOS) {
      return await _channel.invokeMethod('isAccessAllowed');
    }
    return true;
  }

  Future<void> requestAccess({
    bool onlyOpenPrefPane = false,
  }) async {
    if (!kIsWeb && Platform.isMacOS) {
      final Map<String, dynamic> arguments = {
        'onlyOpenPrefPane': onlyOpenPrefPane,
      };
      await _channel.invokeMethod('requestAccess', arguments);
    }
  }

  Future<bool> simulateCtrlCKeyPress() async {
    return await _channel.invokeMethod('simulateCtrlCKeyPress', {});
  }

  Future<ExtractedData> extractFromClipboard() async {
    ClipboardData? d = await Clipboard.getData(Clipboard.kTextPlain);
    return ExtractedData(text: d?.text ?? '');
  }

  Future<ExtractedData> extractFromScreenSelection({
    bool useAccessibilityAPIFirst = false,
  }) async {
    ExtractedData extractedData = ExtractedData(text: '');

    if (Platform.isWindows) {
      // 通过模拟按下 Ctrl+C 快捷键以达到取词的目的。
      await simulateCtrlCKeyPress();
      await Future.delayed(Duration(milliseconds: 500));
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
