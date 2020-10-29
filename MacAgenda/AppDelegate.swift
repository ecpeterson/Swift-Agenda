//
//  AppDelegate.swift
//  MacAgenda
//
//  Created by Eric Peterson on 10/16/20.
//

import Cocoa
import SwiftUI

struct AgendaAppView: View {
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        ZStack {
            if self.settings.loggedIn {
                AgendaListView()
                    .environmentObject(settings)
                AgendaLoginView()
                    .environmentObject(settings)
                    .hidden()
            } else {
                AgendaListView()
                    .environmentObject(settings)
                    .hidden()
                AgendaLoginView()
                    .environmentObject(settings)
            }
        }
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let settings = UserSettings()
        let contentView = AgendaAppView().environmentObject(settings)

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

