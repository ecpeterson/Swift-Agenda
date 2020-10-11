//
//  AgendaApp.swift
//  Agenda
//
//  Created by Eric Peterson on 10/6/20.
//

import SwiftUI

class UserSettings: ObservableObject {
    @Published var loggedIn : Bool = false
    var cxn: ServerConnection = ServerConnection()
    
    // TODO: on init, test whether logged in by a server query
}

@main
struct AgendaApp: App {
    @StateObject var settings: UserSettings = UserSettings()
    
    var body: some Scene {
        WindowGroup {
            if settings.loggedIn {
                AgendaListView()
                    .environmentObject(settings)
            } else {
                AgendaLoginView()
                    .environmentObject(settings)
            }
        }
    }
}
