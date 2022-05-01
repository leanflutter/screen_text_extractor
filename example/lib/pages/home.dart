import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:preference_list/preference_list.dart';
import 'package:screen_text_extractor/screen_text_extractor.dart';

final hotKeyManager = HotKeyManager.instance;
final screenTextExtractor = ScreenTextExtractor.instance;

final kShortcutExtractFromClipboard =
    HotKey(KeyCode.keyZ, modifiers: [KeyModifier.alt]);
final kShortcutExtractFromScreenSelection =
    HotKey(KeyCode.keyX, modifiers: [KeyModifier.alt]);

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

    setState(() {});
  }

  void _handleExtractTextFromClipboard() async {
    print('_handleExtractTextFromClipboard');
    ExtractedData? extractedData = await screenTextExtractor.extract(
      mode: ExtractMode.clipboard,
    );
    BotToast.showText(text: 'extractedData: ${extractedData?.toJson()}');
  }

  void _handleExtractTextFromScreenSelection() async {
    print('_handleExtractTextFromScreenSelection');
    ExtractedData? extractedData = await screenTextExtractor.extract(
      mode: ExtractMode.screenSelection,
    );
    print(extractedData?.toJson());
    BotToast.showText(text: 'extractedData: ${extractedData?.toJson()}');
  }

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        PreferenceListSection(
          title: Text('METHODS'),
          children: [
            PreferenceListItem(
              title: Text('extractTextFromClipboard'),
              detailText: Text(kShortcutExtractFromClipboard.toString()),
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
