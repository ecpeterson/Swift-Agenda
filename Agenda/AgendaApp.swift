//
//  AgendaApp.swift
//  Agenda
//
//  Created by Eric Peterson on 10/6/20.
//

import SwiftUI

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
