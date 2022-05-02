import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:screen_text_extractor/screen_text_extractor.dart';

void main() {
  const MethodChannel channel = MethodChannel('screen_text_extractor');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
