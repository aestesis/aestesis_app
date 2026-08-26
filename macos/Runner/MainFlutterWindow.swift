import Cocoa
import FlutterMacOS
import aestesis_alib

class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)
        
        RegisterGeneratedPlugins(registry: flutterViewController)
        if let del =  NSApplication.shared.delegate as? AppDelegate {
            let document = del.document
            Debug.info("doc: \(document ?? "none")")
        }
        super.awakeFromNib()
    }
}
