import Carbon
import Cocoa
import FlutterMacOS

public class ScreenTextExtractorPlugin: NSObject, FlutterPlugin {
    let tmpDir: String = NSTemporaryDirectory()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "screen_text_extractor", binaryMessenger: registrar.messenger)
        let instance = ScreenTextExtractorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isAllowedScreenCaptureAccess":
            isAllowedScreenCaptureAccess(call, result: result)
            break
        case "requestScreenCaptureAccess":
            requestScreenCaptureAccess(call, result: result)
            break
        case "isAllowedScreenSelectionAccess":
            isAllowedScreenSelectionAccess(call, result: result)
            break
        case "requestScreenSelectionAccess":
            requestScreenSelectionAccess(call, result: result)
            break
        case "extractFromScreenCapture":
            extractFromScreenCapture(call, result: result)
            break
        case "extractFromScreenSelection":
            extractFromScreenSelection(call, result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func isAllowedScreenCaptureAccess(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if #available(macOS 10.15, *) {
            result(CGPreflightScreenCaptureAccess())
        } else {
            // Fallback on earlier versions
            result(false)
        };
    }
    
    public func requestScreenCaptureAccess(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let onlyOpenPrefPane: Bool = args["onlyOpenPrefPane"] as! Bool
        
        if (!onlyOpenPrefPane) {
            if #available(macOS 10.15, *) {
                CGRequestScreenCaptureAccess()
            } else {
                // Fallback on earlier versions
            }
        } else {
            let prefpaneUrl = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!
            NSWorkspace.shared.open(prefpaneUrl)
        }
        result(true)
    }
    
    public func isAllowedScreenSelectionAccess(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(AXIsProcessTrusted())
    }
    
    public func requestScreenSelectionAccess(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let onlyOpenPrefPane: Bool = args["onlyOpenPrefPane"] as! Bool
        
        if (!onlyOpenPrefPane) {
            let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true] as CFDictionary
            AXIsProcessTrustedWithOptions(options)
        } else  {
            let prefpaneUrl = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
            NSWorkspace.shared.open(prefpaneUrl)
        }
        result(true)
    }
    
    public func extractFromScreenCapture(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let imagePath: String = args["imagePath"] as! String
        
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-r", imagePath]
        task.launch()
        task.waitUntilExit()
        
        let resultData: NSDictionary = [
            "imagePath": imagePath,
        ]
        result(resultData)
    }
    
    public func extractFromScreenSelection(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let simulateCopyShortcut: Bool = args["simulateCopyShortcut"] as! Bool
        
        var text: String = ""
        
        let systemWideElement = AXUIElementCreateSystemWide()
        var focusedElement : AnyObject?
        
        let error = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        if (error == .success){
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
        }
        
        // 通过模拟按下 Command+C 键以提取选中的文字
        if (text.isEmpty && simulateCopyShortcut) {
            let copiedString = NSPasteboard.general.string(forType: .string)
            
            let eventKeyDown = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(UInt32(kVK_ANSI_C)), keyDown: true);
            eventKeyDown!.flags = CGEventFlags.maskCommand;
            eventKeyDown!.post(tap: CGEventTapLocation.cghidEventTap);
            
            let deadlineTime = DispatchTime.now() + .milliseconds(100)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                text = NSPasteboard.general.string(forType: .string) ?? "";
                if (!((copiedString ?? "").isEmpty)) {
                    NSPasteboard.general.pasteboardItems?.first?.setString(copiedString!, forType: .string)
                } else {
                    NSPasteboard.general.clearContents()
                }
                
                let resultData: NSDictionary = ["text": text]
                result(resultData)
            }
        } else {
            let resultData: NSDictionary = ["text": text]
            result(resultData)
        }
    }
}
