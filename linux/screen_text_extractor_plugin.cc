#include "include/screen_text_extractor/screen_text_extractor_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#define SCREEN_TEXT_EXTRACTOR_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), screen_text_extractor_plugin_get_type(), \
                              ScreenTextExtractorPlugin))

struct _ScreenTextExtractorPlugin
{
  GObject parent_instance;
};

G_DEFINE_TYPE(ScreenTextExtractorPlugin, screen_text_extractor_plugin, g_object_get_type())

static FlMethodResponse *extract_from_screen_selection(ScreenTextExtractorPlugin *self,
                                                       FlValue *args)
{
  GtkClipboard *clipboard = gtk_clipboard_get(GDK_SELECTION_PRIMARY);
  gchar *text = gtk_clipboard_wait_for_text(clipboard);

  g_autoptr(FlValue) result_data = fl_value_new_map();
  fl_value_set_string_take(result_data, "text", fl_value_new_string(text));

  return FL_METHOD_RESPONSE(fl_method_success_response_new(result_data));
}

// Called when a method call is received from Flutter.
static void screen_text_extractor_plugin_handle_method_call(
    ScreenTextExtractorPlugin *self,
    FlMethodCall *method_call)
{
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar *method = fl_method_call_get_name(method_call);
  FlValue *args = fl_method_call_get_args(method_call);

  if (strcmp(method, "extractFromScreenSelection") == 0)
  {
    response = extract_from_screen_selection(self, args);
  }
  else
  {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void screen_text_extractor_plugin_dispose(GObject *object)
{
  G_OBJECT_CLASS(screen_text_extractor_plugin_parent_class)->dispose(object);
}

static void screen_text_extractor_plugin_class_init(ScreenTextExtractorPluginClass *klass)
{
  G_OBJECT_CLASS(klass)->dispose = screen_text_extractor_plugin_dispose;
}

static void screen_text_extractor_plugin_init(ScreenTextExtractorPlugin *self) {}

static void method_call_cb(FlMethodChannel *channel, FlMethodCall *method_call,
                           gpointer user_data)
{
  ScreenTextExtractorPlugin *plugin = SCREEN_TEXT_EXTRACTOR_PLUGIN(user_data);
  screen_text_extractor_plugin_handle_method_call(plugin, method_call);
}

void screen_text_extractor_plugin_register_with_registrar(FlPluginRegistrar *registrar)
{
  ScreenTextExtractorPlugin *plugin = SCREEN_TEXT_EXTRACTOR_PLUGIN(
      g_object_new(screen_text_extractor_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "screen_text_extractor",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
