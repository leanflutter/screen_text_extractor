import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:flutter/material.dart';

class ClipboardOnceWatcher with ClipboardListener {
  VoidCallback? onChange;

  Future<void> watch({
    VoidCallback? onChange,
    VoidCallback? onTimeout,
  }) async {
    this.onChange = onChange;
    Future.delayed(Duration(milliseconds: 3000)).then((value) {
      if (onTimeout != null) {
        onTimeout();
      }
    });
    clipboardWatcher.addListener(this);
    await clipboardWatcher.start();
  }

  Future<void> stop() async {
    clipboardWatcher.removeListener(this);
    await clipboardWatcher.stop();
  }

  @override
  void onClipboardChanged() async {
    await stop();
    if (onChange != null) {
      onChange!();
      onChange = null;
    }
  }
}
