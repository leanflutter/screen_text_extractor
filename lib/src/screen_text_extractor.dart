import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'extract_mode.dart';
import 'extracted_data.dart';
import 'clipboard_once_watcher.dart';

class ScreenTextExtractor {
  ScreenTextExtractor._();

  /// The shared instance of [ScreenTextExtractor].
  static final ScreenTextExtractor instance = ScreenTextExtractor._();

  final MethodChannel _channel = const MethodChannel('screen_text_extractor');

  final ClipboardOnceWatcher _clipboardOnceWatcher = ClipboardOnceWatcher();

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

  Future<ExtractedData?> extract({
    ExtractMode mode = ExtractMode.clipboard,
  }) async {
    if (mode == ExtractMode.clipboard) {
      return await _extractFromClipboard();
    } else if (mode == ExtractMode.screenSelection) {
      return await _extractFromScreenSelection();
    } else {
      throw ArgumentError('Invalid extract mode: $mode');
    }
  }

  Future<bool> _simulateCtrlCKeyPress() async {
    return await _channel.invokeMethod('simulateCtrlCKeyPress', {});
  }

  Future<ExtractedData?> _extractFromClipboard() async {
    ClipboardData? d = await Clipboard.getData(Clipboard.kTextPlain);
    if (d == null) return null;
    return ExtractedData(text: d.text ?? '');
  }

  Future<ExtractedData?> _extractFromScreenSelection() async {
    if (Platform.isWindows || Platform.isMacOS) {
      Completer<ExtractedData?> completer = Completer<ExtractedData?>();

      await _clipboardOnceWatcher.watch(
        onChange: () {
          if (completer.isCompleted) return;
          completer.complete(_extractFromClipboard());
        },
        onTimeout: () {
          if (completer.isCompleted) return;
          completer.complete(null);
        },
      );

      // 通过模拟按下 Ctrl+C 快捷键以达到取词的目的。
      await _simulateCtrlCKeyPress();
      return completer.future;
    } else {
      final Map<dynamic, dynamic> resultData = await _channel.invokeMethod(
        'extractFromScreenSelection',
      );

      return ExtractedData.fromJson(
        Map<String, dynamic>.from(resultData),
      );
    }
  }
}

final screenTextExtractor = ScreenTextExtractor.instance;
