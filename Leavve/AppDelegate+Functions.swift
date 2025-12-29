import Cocoa

extension AppDelegate {
    
    @objc func openAbout() {
        AboutWindowController.createWindow()
    }
    
    @objc func quit() {
        NSApp.terminate(self)
    }

    func closePopover() {
        popover.close()
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        let event = NSApp.currentEvent!

        if event.type == NSEvent.EventType.leftMouseUp {
            if let sbutton = statusBarItem.button {
                if popover.isShown {
                    popover.performClose(sender)
                } else {
                    // find the coordinates of the statusBarItem in screen space
                    let buttonRect: NSRect = sbutton.convert(sbutton.bounds, to: nil)
                    let screenRect: NSRect = sbutton.window!.convertToScreen(buttonRect)

                    // calculate the bottom center position (10 is the half of the window width)
                    let posX = screenRect.origin.x + (screenRect.width / 2) - 10
                    let posY = screenRect.origin.y

                    // position and show the window
                    invisibleWindow.setFrameOrigin(NSPoint(x: posX, y: posY))
                    invisibleWindow.makeKeyAndOrderFront(self)
                    NSApplication.shared.presentationOptions = []
                    // position and show the NSPopover
                    popover.show(relativeTo: invisibleWindow.contentView!.frame, of: invisibleWindow.contentView!, preferredEdge: NSRectEdge.minY)
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        } else if event.type == NSEvent.EventType.rightMouseUp {
            let menu = NSMenu()
            menu.addItem(withTitle: "About Leavve", action: #selector(openAbout), keyEquivalent: "")
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Leavve v1.0", action: nil, keyEquivalent: ""))
            menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q")

            statusBarItem.menu = menu
            statusBarItem.button?.performClick(nil)
            statusBarItem.menu = nil
        }
    }
}
