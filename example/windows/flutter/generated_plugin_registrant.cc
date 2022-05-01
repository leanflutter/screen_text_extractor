//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <clipboard_watcher/clipboard_watcher_plugin.h>
#include <hotkey_manager/hotkey_manager_plugin.h>
#include <screen_text_extractor/screen_text_extractor_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  ClipboardWatcherPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ClipboardWatcherPlugin"));
  HotkeyManagerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("HotkeyManagerPlugin"));
  ScreenTextExtractorPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenTextExtractorPlugin"));
}
