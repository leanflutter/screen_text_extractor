#include "include/screen_text_extractor/screen_text_extractor_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <codecvt>
#include <map>
#include <memory>
#include <sstream>
#include <fstream>
#include <atlimage.h>

namespace {

    class ScreenTextExtractorPlugin : public flutter::Plugin {
    public:
        static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

        ScreenTextExtractorPlugin();

        virtual ~ScreenTextExtractorPlugin();

    private:
        flutter::PluginRegistrarWindows* registrar;
        // Called when a method is called on this plugin's channel from Dart.
        void HandleMethodCall(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

        void ScreenTextExtractorPlugin::ExtractFromScreenCapture(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
        void ScreenTextExtractorPlugin::ExtractFromScreenSelection(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    };

    // static
    void ScreenTextExtractorPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarWindows* registrar) {
        auto channel =
            std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
                registrar->messenger(), "screen_text_extractor",
                &flutter::StandardMethodCodec::GetInstance());

        auto plugin = std::make_unique<ScreenTextExtractorPlugin>();

        channel->SetMethodCallHandler(
            [plugin_pointer = plugin.get()](const auto& call, auto result)
        {
            plugin_pointer->HandleMethodCall(call, std::move(result));
        });

        registrar->AddPlugin(std::move(plugin));
    }

    ScreenTextExtractorPlugin::ScreenTextExtractorPlugin() {}

    ScreenTextExtractorPlugin::~ScreenTextExtractorPlugin() {}

    void ScreenTextExtractorPlugin::ExtractFromScreenCapture(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        const flutter::EncodableMap& args = std::get<flutter::EncodableMap>(*method_call.arguments());

        std::string imagePath = std::get<std::string>(args.at(flutter::EncodableValue("imagePath")));

        std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
        ShellExecute(
            NULL,
            converter.from_bytes("open").c_str(),
            converter.from_bytes("ms-screenclip:").c_str(),
            NULL,
            NULL,
            SW_SHOWNORMAL);

        // HBITMAP bitmap = NULL;

        // std::vector<BYTE> buf;
        // IStream *stream = NULL;
        // CreateStreamOnHGlobal(0, TRUE, &stream);
        // CImage image;
        // ULARGE_INTEGER liSize;

        // // screenshot to png and save to stream
        // image.Attach(bitmap);
        // image.Save(stream, Gdiplus::ImageFormatPNG);
        // IStream_Size(stream, &liSize);
        // DWORD len = liSize.LowPart;
        // IStream_Reset(stream);
        // buf.resize(len);
        // IStream_Read(stream, &buf[0], len);
        // stream->Release();

        // // put the imapge in the file
        // std::fstream fi;
        // fi.open(imagePath, std::fstream::binary | std::fstream::out);
        // fi.write(reinterpret_cast<const char *>(&buf[0]), buf.size() * sizeof(BYTE));
        // fi.close();

        // OpenClipboard(nullptr);
        // EmptyClipboard();
        // HANDLE clipboardData = GetClipboardData(CF_DIB);
        // if (clipboardData != NULL && clipboardData != INVALID_HANDLE_VALUE)
        // {
        //   void *dib = GlobalLock(clipboardData);

        //   if (dib)
        //   {
        //     GlobalUnlock(dib);
        //   }
        // }
        // CloseClipboard();

        flutter::EncodableMap resultMap = flutter::EncodableMap();
        resultMap[flutter::EncodableValue("imagePath")] = flutter::EncodableValue(imagePath);

        result->Success(flutter::EncodableValue(resultMap));
    }


    void ScreenTextExtractorPlugin::ExtractFromScreenSelection(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        
        flutter::EncodableMap resultMap = flutter::EncodableMap();
        resultMap[flutter::EncodableValue("text")] = flutter::EncodableValue("text");

        result->Success(flutter::EncodableValue(resultMap));
    }

    void ScreenTextExtractorPlugin::HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (method_call.method_name().compare("extractFromScreenCapture") == 0) {
            ExtractFromScreenCapture(method_call, std::move(result));
        }
        else if (method_call.method_name().compare("extractFromScreenSelection") == 0) {
            ExtractFromScreenSelection(method_call, std::move(result));
        }
        else {
            result->NotImplemented();
        }
    }

} // namespace

void ScreenTextExtractorPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
    ScreenTextExtractorPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarManager::GetInstance()
        ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
