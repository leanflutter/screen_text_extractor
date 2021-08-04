//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <screen_text_extractor/screen_text_extractor_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) screen_text_extractor_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "ScreenTextExtractorPlugin");
  screen_text_extractor_plugin_register_with_registrar(screen_text_extractor_registrar);
}
