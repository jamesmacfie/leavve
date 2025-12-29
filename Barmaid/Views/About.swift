//
//  About.swift
//  Leavve
//
//  Created by Steven J. Selcuk on 2.05.2022.
//

import Cocoa
import SwiftUI

struct AboutView: View {
    var nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject

    var body: some View {
        let version = nsObject as! String
        VStack(alignment: .center, spacing: 10) {
            Spacer()
            VStack(alignment: .center) {
                Image("Barmaid")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)

                Text("Leavve")
                    .bold()
                    .font(.title)

                Text("v\(version)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Leave tracking for teams using Runn")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            .padding(.vertical, 10.0)
            Spacer()
        }.padding(.horizontal, 10.0)
            .background(Color.clear)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
    }
}

class AboutWindowController {
    static func createWindow() {
        var windowRef: NSWindow
        windowRef = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 280),
            styleMask: [
                .titled,
                .closable,
                .borderless],
            backing: .buffered, defer: false)
        windowRef.contentView = NSHostingView(rootView: AboutView())
        windowRef.title = "About Leavve"
        windowRef.level = NSWindow.Level.screenSaver
        windowRef.isReleasedWhenClosed = false
        windowRef.makeKeyAndOrderFront(nil)
    }
}
