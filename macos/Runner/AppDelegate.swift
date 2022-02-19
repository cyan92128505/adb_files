import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
    let channel = FlutterMethodChannel.init(name: "angjelko.io/adb-files", binaryMessenger: controller.engine.binaryMessenger)
    channel.setMethodCallHandler({
      (_ call: FlutterMethodCall, _ result: FlutterResult) -> Void in
        if("chooseDirectory" == call.method){
            self.chooseDirectory(result: result);
        }
    });
  }

  private func chooseDirectory(result: FlutterResult) {
    let openPanel = NSOpenPanel()
    openPanel.title = "Choose Directory";
    openPanel.showsResizeIndicator = true;
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = true
    openPanel.canCreateDirectories = true
    openPanel.canChooseFiles = false
    
    if (openPanel.runModal() == NSApplication.ModalResponse.OK) {
      let result1 = openPanel.urls
      if (result1.count > 0) {
        let file = result1[0]
        result(file.path);
      }
    } else {
        result("");
    }
  }
}
