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
        case "requestEnable":
            requestEnable(call, result: result)
            break
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
    
    public func requestEnable(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let prefpaneUrl = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(prefpaneUrl)
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
            result(FlutterError(code: "unknown", message: "Couldn't get the focused element.", details: nil))
            return
        }
        
        var selectedTextValue: AnyObject?
        let selectedTextError = AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, kAXSelectedTextAttribute as CFString, &selectedTextValue)
        if (selectedTextError == .success) {
            text = selectedTextValue as! String
        }
        
        if (text.isEmpty) {
            // Extract text in the WebKit application
            var selectedTextMarkerRangeValue: AnyObject?
            let selectedTextMarkerRangeError = AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, "AXSelectedTextMarkerRange" as CFString, &selectedTextMarkerRangeValue);
            if (selectedTextMarkerRangeError == .success) {
                var stringForTextMarkerRangeValue: AnyObject?
                let stringForTextMarkerRangeError = AXUIElementCopyParameterizedAttributeValue(focusedElement as! AXUIElement, "AXAttributedStringForTextMarkerRange" as CFString, selectedTextMarkerRangeValue!, &stringForTextMarkerRangeValue);
                if (stringForTextMarkerRangeError == .success) {
                    text = (stringForTextMarkerRangeValue as! NSAttributedString).string
                }
            }
        }
        
        let resultData: NSDictionary = [
            "text": text,
        ]
        result(resultData)
    }
}
