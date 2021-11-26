#include "include/screen_text_extractor/screen_text_extractor_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>

namespace
{
class ScreenTextExtractorPlugin : public flutter::Plugin
{
  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

    ScreenTextExtractorPlugin();

    virtual ~ScreenTextExtractorPlugin();

  private:
    flutter::PluginRegistrarWindows *registrar;
    void ScreenTextExtractorPlugin::SimulateCtrlCKeyPress(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                          std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

// static
void ScreenTextExtractorPlugin::RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar)
{
    auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
        registrar->messenger(), "screen_text_extractor", &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<ScreenTextExtractorPlugin>();

    channel->SetMethodCallHandler([plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
    });

    registrar->AddPlugin(std::move(plugin));
}

ScreenTextExtractorPlugin::ScreenTextExtractorPlugin()
{
}

ScreenTextExtractorPlugin::~ScreenTextExtractorPlugin()
{
}

void ScreenTextExtractorPlugin::SimulateCtrlCKeyPress(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
{

    // Wait until all modifiers will be unpressed (to avoid conflicts with the other shortcuts)
    while (GetAsyncKeyState(VK_LWIN) || GetAsyncKeyState(VK_RWIN) || GetAsyncKeyState(VK_SHIFT) ||
           GetAsyncKeyState(VK_MENU) || GetAsyncKeyState(VK_CONTROL))
    {
    };

    // Generate Ctrl + C input
    INPUT copyText[4];

    // Set the press of the "Ctrl" key
    copyText[0].ki.wVk = VK_CONTROL;
    copyText[0].ki.dwFlags = 0; // 0 for key press
    copyText[0].type = INPUT_KEYBOARD;

    // Set the press of the "C" key
    copyText[1].ki.wVk = 'C';
    copyText[1].ki.dwFlags = 0;
    copyText[1].type = INPUT_KEYBOARD;

    // Set the release of the "C" key
    copyText[2].ki.wVk = 'C';
    copyText[2].ki.dwFlags = KEYEVENTF_KEYUP;
    copyText[2].type = INPUT_KEYBOARD;

    // Set the release of the "Ctrl" key
    copyText[3].ki.wVk = VK_CONTROL;
    copyText[3].ki.dwFlags = KEYEVENTF_KEYUP;
    copyText[3].type = INPUT_KEYBOARD;

    // Send key sequence to system
    SendInput(static_cast<UINT>(std::size(copyText)), copyText, sizeof(INPUT));

    result->Success(flutter::EncodableValue(true));
}

void ScreenTextExtractorPlugin::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                                                 std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
{
    if (method_call.method_name().compare("simulateCtrlCKeyPress") == 0)
    {
        SimulateCtrlCKeyPress(method_call, std::move(result));
    }
    else
    {
        result->NotImplemented();
    }
}

} // namespace

void ScreenTextExtractorPluginRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar)
{
    ScreenTextExtractorPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarManager::GetInstance()->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
