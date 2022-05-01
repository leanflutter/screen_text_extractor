import Carbon
import Cocoa
import FlutterMacOS

public class ScreenTextExtractorPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "screen_text_extractor", binaryMessenger: registrar.messenger)
        let instance = ScreenTextExtractorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "simulateCtrlCKeyPress":
            simulateCtrlCKeyPress(call, result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func simulateCtrlCKeyPress(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let eventKeyDown = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(UInt32(kVK_ANSI_C)), keyDown: true);
        eventKeyDown!.flags = CGEventFlags.maskCommand;
        eventKeyDown!.post(tap: CGEventTapLocation.cghidEventTap);
        result(true)
    }
}
