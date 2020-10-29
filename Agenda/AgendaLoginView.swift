//
//  AgendaLoginView.swift
//  Agenda
//
//  Created by Eric Peterson on 10/10/20.
//

import SwiftUI

struct AgendaLoginView: View {
    @State var username: String = ""
    @State var password: String = ""
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        VStack {
            Text("Log in")
                .font(.title)
            
            Spacer()
            
            #if os(iOS)
            TextField("User name", text: $username)
                .padding()
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.emailAddress)
            #else
            TextField("User name", text: $username)
                .padding()
                .disableAutocorrection(true)
            #endif
            SecureField("Password", text: $password)
                .padding()
            
            Spacer()
            
            HStack {
                Button("Sign up", action: register)
                Spacer()
                Button("Log in", action: logIn)
            }
        }.padding()
    }
    
    // TODO: display spinner during login process
    func logIn() {
        let cxn = settings.cxn
        // TODO: there's some threading warning here...
        cxn.login(username: self.username,
                  password: self.password,
                  doneCallback: { loginResult in
                    DispatchQueue.main.async {
                        settings.loggedIn = loginResult["loggedIn"] == "true"
                    }
                  })
    }
    
    func register() {
        let cxn = settings.cxn
        cxn.signup(username: self.username,
                   password: self.password,
                   doneCallback: { loginResult in
                    DispatchQueue.main.async {
                        settings.loggedIn = loginResult["loggedIn"] == "true"
                    }
                   })
    }
}

struct AgendaLoginView_Previews: PreviewProvider {
    static var previews: some View {
        AgendaLoginView()
    }
}
