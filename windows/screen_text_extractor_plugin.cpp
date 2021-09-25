#include "include/screen_text_extractor/screen_text_extractor_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <atlimage.h>
#include <codecvt>
#include <fstream>
#include <map>
#include <memory>
#include <sstream>
#include <thread>

const char kExtractFromScreenCapture[] = "extractFromScreenCapture";
const char kExtractFromScreenSelection[] = "extractFromScreenSelection";

namespace
{
std::string last_method_call_name;
std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> last_method_call_result;

class ScreenTextExtractorPlugin : public flutter::Plugin
{
  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

    ScreenTextExtractorPlugin();

    virtual ~ScreenTextExtractorPlugin();

  private:
    flutter::PluginRegistrarWindows *registrar;

    void ScreenTextExtractorPlugin::ExtractFromScreenCapture(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    void ScreenTextExtractorPlugin::ExtractFromScreenSelection(
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

void *ExtractFromScreenCaptureThread(std::string imagePath)
{
    if (last_method_call_name != kExtractFromScreenCapture)
        return 0;

    int loop_count = 0;
    while (loop_count < 300)
    {
        Sleep(10);
        loop_count++;

        HBITMAP bitmap = NULL;

        OpenClipboard(nullptr);
        bitmap = (HBITMAP)GetClipboardData(CF_BITMAP);
        CloseClipboard();

        if (bitmap == NULL)
        {
            continue;
        }

        std::vector<BYTE> buf;
        IStream *stream = NULL;
        CreateStreamOnHGlobal(0, TRUE, &stream);
        CImage image;
        ULARGE_INTEGER liSize;

        // screenshot to png and save to stream
        image.Attach(bitmap);
        image.Save(stream, Gdiplus::ImageFormatPNG);
        IStream_Size(stream, &liSize);
        DWORD len = liSize.LowPart;
        IStream_Reset(stream);
        buf.resize(len);
        IStream_Read(stream, &buf[0], len);
        stream->Release();

        // put the imapge in the file
        std::fstream fi;
        fi.open(imagePath, std::fstream::binary | std::fstream::out);
        fi.write(reinterpret_cast<const char *>(&buf[0]), buf.size() * sizeof(BYTE));
        fi.close();
    }

    flutter::EncodableMap resultMap = flutter::EncodableMap();
    resultMap[flutter::EncodableValue("imagePath")] = flutter::EncodableValue(imagePath.c_str());

    last_method_call_result->Success(flutter::EncodableValue(resultMap));

    return 0;
}

std::string Utf8FromUtf16(const std::wstring_view utf16_string)
{
    if (utf16_string.empty())
    {
        return std::string();
    }
    int target_length = ::WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, utf16_string.data(),
                                              static_cast<int>(utf16_string.length()), nullptr, 0, nullptr, nullptr);
    if (target_length == 0)
    {
        return std::string();
    }
    std::string utf8_string;
    utf8_string.resize(target_length);
    int converted_length = ::WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, utf16_string.data(),
                                                 static_cast<int>(utf16_string.length()), utf8_string.data(),
                                                 target_length, nullptr, nullptr);
    if (converted_length == 0)
    {
        return std::string();
    }
    return utf8_string;
}

std::optional<std::wstring> GetClipboardString()
{
    HANDLE clipboardData = ::GetClipboardData(CF_UNICODETEXT);
    if (clipboardData == nullptr)
    {
        return std::nullopt;
    }
    void *locked_memory = ::GlobalLock(clipboardData);
    return std::optional<std::wstring>(static_cast<wchar_t *>(locked_memory));
}

void *ExtractFromScreenSelectionThread()
{
    if (last_method_call_name != kExtractFromScreenSelection)
        return 0;

    Sleep(300);

    std::optional<std::wstring> clipboard_string = std::nullopt;

    OpenClipboard(nullptr);
    HANDLE clipboardData = GetClipboardData(CF_UNICODETEXT);
    if (clipboardData != nullptr)
    {
        void *locked_memory = ::GlobalLock(clipboardData);
        clipboard_string = std::optional<std::wstring>(static_cast<wchar_t *>(locked_memory));
    }
    GlobalUnlock(clipboardData);
    CloseClipboard();

    flutter::EncodableMap resultMap = flutter::EncodableMap();
    resultMap[flutter::EncodableValue("text")] = flutter::EncodableValue(Utf8FromUtf16(*clipboard_string).c_str());

    last_method_call_result->Success(flutter::EncodableValue(resultMap));
    return 0;
}

void ScreenTextExtractorPlugin::ExtractFromScreenCapture(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
{
    const flutter::EncodableMap &args = std::get<flutter::EncodableMap>(*method_call.arguments());

    std::string imagePath = std::get<std::string>(args.at(flutter::EncodableValue("imagePath")));

    OpenClipboard(nullptr);
    EmptyClipboard();
    CloseClipboard();

    std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
    ShellExecute(NULL, converter.from_bytes("open").c_str(), converter.from_bytes("ms-screenclip:").c_str(), NULL, NULL,
                 SW_SHOWNORMAL);

    last_method_call_name = kExtractFromScreenCapture;
    last_method_call_result = std::move(result);

    std::thread th(ExtractFromScreenCaptureThread, imagePath);
    th.detach();
}

void ScreenTextExtractorPlugin::ExtractFromScreenSelection(
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

    last_method_call_name = kExtractFromScreenSelection;
    last_method_call_result = std::move(result);

    std::thread th(ExtractFromScreenSelectionThread);
    th.detach();
}

void ScreenTextExtractorPlugin::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                                                 std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
{
    if (method_call.method_name().compare(kExtractFromScreenCapture) == 0)
    {
        ExtractFromScreenCapture(method_call, std::move(result));
    }
    else if (method_call.method_name().compare(kExtractFromScreenSelection) == 0)
    {
        ExtractFromScreenSelection(method_call, std::move(result));
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
