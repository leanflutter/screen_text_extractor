
import 'dart:async';

import 'package:flutter/services.dart';

class ScreenTextExtractor {
  static const MethodChannel _channel =
      const MethodChannel('screen_text_extractor');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
