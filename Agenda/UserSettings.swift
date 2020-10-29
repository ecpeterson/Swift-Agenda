//
//  UserSettings.swift
//  Agenda
//
//  Created by Eric Peterson on 10/16/20.
//

import Foundation

class UserSettings: ObservableObject {
    @Published var loggedIn : Bool = false
    var cxn: ServerConnection = ServerConnection()
    
    // TODO: on init, test whether logged in by a server query
}
