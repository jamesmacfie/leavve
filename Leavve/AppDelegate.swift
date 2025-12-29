import Cocoa
import SwiftUI
@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let invisibleWindow = NSWindow(contentRect: NSMakeRect(0, 0, 20, 5), styleMask: .borderless, backing: .buffered, defer: false)
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Clear default menu to suppress menu inconsistency warnings
        NSApp.mainMenu = NSMenu()

        statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        invisibleWindow.backgroundColor = .red
        invisibleWindow.alphaValue = 0

        // Get SwiftUI View
        let contentView = Main()
        // Create a popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 300)
        popover.behavior = .transient
        // Embed our SwiftUI view into the popover
        popover.contentViewController = NSHostingController(rootView: contentView)
        // Register it
        self.popover = popover
        self.popover.contentViewController?.view.window?.becomeKey()

        if let button = statusBarItem.button {
            // Set menubar icon
            if let icon = NSImage(named: "menubar-icon") {
                icon.isTemplate = true
                icon.size = NSSize(width: 18, height: 18)
                button.image = icon
            }
            // Set font
            button.font = NSFont.monospacedDigitSystemFont(ofSize: 12.0, weight: NSFont.Weight.light)
            // Register click action
            // See Functions file
            button.action = #selector(togglePopover(_:))
            // Dispatch click states
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

