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
        case "getPlatformVersion":
            result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
        case "isEnabled":
            isEnabled(call, result: result)
            break
        case "extractFromSelection":
            extractFromSelection(call, result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func isEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(AXIsProcessTrusted())
    }
    
    public func extractFromSelection(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        var text: String = ""
        
        let systemWideElement = AXUIElementCreateSystemWide()
        var focusedElement : AnyObject?
        
        let error = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        if (error != .success){
            print("Couldn't get the focused element.")
        } else {
            var selectedTextValue: AnyObject?
            let selectedTextError = AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, kAXSelectedTextAttribute as CFString, &selectedTextValue)
            if (selectedTextError == .success) {
                text = selectedTextValue as! String
            }
        }
        
        let resultData: NSDictionary = [
            "text": text,
        ]
        result(resultData)
    }
}
