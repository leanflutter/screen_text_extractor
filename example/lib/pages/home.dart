import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:preference_list/preference_list.dart';
import 'package:screen_text_extractor/screen_text_extractor.dart';
import 'package:path_provider/path_provider.dart';

final hotKeyManager = HotKeyManager.instance;
final screenTextExtractor = ScreenTextExtractor.instance;

final kShortcutExtractFromClipboard =
    HotKey(KeyCode.keyZ, modifiers: [KeyModifier.alt]);
final kShortcutExtractFromScreenCapture =
    HotKey(KeyCode.keyX, modifiers: [KeyModifier.alt]);
final kShortcutExtractFromScreenSelection =
    HotKey(KeyCode.keyC, modifiers: [KeyModifier.alt]);

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isAllowedScreenCaptureAccess = false;
  bool _isAllowedScreenSelectionAccess = false;
  bool _isTesseractInstalled = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    // 初始化快捷键
    hotKeyManager.unregisterAll();
    hotKeyManager.register(
      kShortcutExtractFromClipboard,
      keyDownHandler: (_) {
        _handleExtractTextFromClipboard();
      },
    );
    hotKeyManager.register(
      kShortcutExtractFromScreenSelection,
      keyDownHandler: (_) {
        _handleExtractTextFromScreenSelection();
      },
    );
    hotKeyManager.register(
      kShortcutExtractFromScreenCapture,
      keyDownHandler: (_) {
        _handleExtractTextFromScreenCapture();
      },
    );
    _isAllowedScreenCaptureAccess =
        await screenTextExtractor.isAllowedScreenCaptureAccess();
    _isAllowedScreenSelectionAccess =
        await screenTextExtractor.isAllowedScreenSelectionAccess();
    _isTesseractInstalled = await screenTextExtractor.isTesseractInstalled();
    setState(() {});
  }

  void _handleExtractTextFromClipboard() async {
    print('_handleExtractTextFromClipboard');
    ExtractedData extractedData =
        await screenTextExtractor.extractFromClipboard();
    print(extractedData.toJson());
    BotToast.showText(text: 'extractedData: ${extractedData.toJson()}');
  }

  void _handleExtractTextFromScreenCapture() async {
    print('_handleExtractTextFromScreenCapture');
    Directory directory = await getApplicationDocumentsDirectory();
    String fileName = 'Screenshot-${DateTime.now().millisecondsSinceEpoch}.png';
    ExtractedData extractedData =
        await screenTextExtractor.extractFromScreenCapture(
      imagePath:
          '${directory.path}/screen_text_extractor_example/Screenshots/$fileName',
    );
    print(extractedData.toJson());
    BotToast.showText(text: 'extractedData: ${extractedData.toJson()}');
  }

  void _handleExtractTextFromScreenSelection() async {
    print('_handleExtractTextFromScreenSelection');
    ExtractedData extractedData =
        await screenTextExtractor.extractFromScreenSelection();
    print(extractedData.toJson());
    BotToast.showText(text: 'extractedData: ${extractedData.toJson()}');
  }

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        if (Platform.isMacOS)
          PreferenceListSection(
            children: [
              PreferenceListItem(
                title: Text('isAllowedScreenCaptureAccess'),
                accessoryView: Text('$_isAllowedScreenCaptureAccess'),
                onTap: () async {
                  bool allowed = await ScreenTextExtractor.instance
                      .isAllowedScreenCaptureAccess();
                  BotToast.showText(text: 'allowed: $allowed');
                  setState(() {
                    _isAllowedScreenCaptureAccess = allowed;
                  });
                },
              ),
              PreferenceListItem(
                title: Text('requestScreenCaptureAccess'),
                onTap: () async {
                  await ScreenTextExtractor.instance
                      .requestScreenCaptureAccess();
                },
              ),
              PreferenceListItem(
                title: Text('isAllowedScreenSelectionAccess'),
                accessoryView: Text('$_isAllowedScreenSelectionAccess'),
                onTap: () async {
                  bool allowed = await ScreenTextExtractor.instance
                      .isAllowedScreenSelectionAccess();
                  BotToast.showText(text: 'allowed: $allowed');
                  setState(() {
                    _isAllowedScreenSelectionAccess = allowed;
                  });
                },
              ),
              PreferenceListItem(
                title: Text('requestScreenSelectionAccess'),
                onTap: () async {
                  await ScreenTextExtractor.instance
                      .requestScreenSelectionAccess();
                },
              ),
            ],
          ),
        PreferenceListSection(
          title: Text('METHODS'),
          children: [
            PreferenceListItem(
              title: Text('isTesseractInstalled'),
              accessoryView: Text('$_isTesseractInstalled'),
              onTap: () async {
                _isTesseractInstalled =
                    await ScreenTextExtractor.instance.isTesseractInstalled();
                BotToast.showText(
                    text: 'isTesseractInstalled: $_isTesseractInstalled');
                setState(() {});
              },
            ),
            PreferenceListItem(
              title: Text('extractTextFromClipboard'),
              detailText: Text(kShortcutExtractFromClipboard.toString()),
            ),
            PreferenceListItem(
              title: Text('extractTextFromScreenCapture'),
              detailText: Text(kShortcutExtractFromScreenCapture.toString()),
            ),
            PreferenceListItem(
              title: Text('extractTextFromScreenSelection'),
              detailText: Text(kShortcutExtractFromScreenSelection.toString()),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: _buildBody(context),
    );
  }
}
