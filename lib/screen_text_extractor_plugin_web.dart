import 'dart:async';
// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;
import 'dart:js' as js;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// A web implementation of the ScreenTextExtractor plugin.
class ScreenTextExtractorPlugin {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'screen_text_extractor',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = ScreenTextExtractorPlugin();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'extractFromScreenCapture':
        return extractFromScreenCapture(call);
      case 'extractFromScreenSelection':
        return extractFromScreenSelection(call);
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'screen_text_extractor for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  Future<Map<dynamic, dynamic>> extractFromScreenCapture(
    MethodCall call,
  ) {
    Completer<Map<dynamic, dynamic>> completer = Completer();
    js.context.callMethod(
      'screenTextExtractorExtractFromScreenCapture',
      [
        js.JsFunction.withThis((_, dynamic data) {
          completer.complete({
            'imageWidth': data['imageWidth'],
            'imageHeight': data['imageHeight'],
            'base64Image': data['base64Image'],
          });
        })
      ],
    );
    return completer.future;
  }

  Future<Map<dynamic, dynamic>> extractFromScreenSelection(MethodCall call) {
    js.JsObject resultData = js.context.callMethod(
      'screenTextExtractorExtractFromScreenSelection',
      [],
    );
    return Future.value({
      'text': resultData['text'],
    });
  }
}
