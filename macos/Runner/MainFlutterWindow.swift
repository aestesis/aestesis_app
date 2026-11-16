import Cocoa
import FlutterMacOS
import aestesis_alib

class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = NSRect(x: 0, y: 0, width: 0, height: 0)
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: false)
        
        RegisterGeneratedPlugins(registry: flutterViewController)
        if let del =  NSApplication.shared.delegate as? AppDelegate {
            let document = del.document
            Debug.info("doc: \(document ?? "none")")
        }
        super.awakeFromNib()
    }
}
