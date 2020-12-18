//
//  ServerComms.swift
//  Agenda
//
//  Created by Eric Peterson on 10/9/20.
//

import Foundation

let server = "https://agenda.chromotopy.org"

enum ServerCommsError: Error {
    case noDataReceived
    case loggedOut
    case remoteError(String)
    case noURLResponse
    case unknownRemoteError(Int)
}

class ServerConnection: ObservableObject {
    // COMMUNICATION CONFIGURATION =============================================
    
    let baseURL = URL(string: server + ":8091")
    let session = URLSession(configuration: .default)
    
    // COMMUNICATION WRAPPERS ==================================================

    func login(username: String,
               password: String,
               doneCallback: @escaping (([String: String]) -> ()),
               errorCallback: ((Error) -> ())? = nil) {
        
        let parameters: [String: String] = [
            "email": username,
            "password": password
        ]
        
        communicate(uri: "/login",
                    requestType: "POST",
                    body: parameters,
                    doneCallback: doneCallback,
                    errorCallback: errorCallback)
    }
    
    func signup(username: String,
                password: String,
                doneCallback: @escaping (([String: String]) -> ()),
                errorCallback: ((Error) -> ())? = nil) {
        
        let parameters: [String: String] = [
            "email": username,
            "password": password
        ]
        
        communicate(uri: "/signup",
                    requestType: "POST",
                    body: parameters,
                    doneCallback: doneCallback,
                    errorCallback: errorCallback)
    }

    func refresh(doneCallback: @escaping (([String: [AgendaItem]]) -> ()),
                 errorCallback: ((Error) -> ())? = nil) {
        let body : [String: Int] = ["date": DateOnly().int()]
        communicate(uri: "/todo",
                    requestType: "POST",  // this really ought to be GET, but Swift fucks it up
                    body: body,
                    doneCallback: doneCallback,
                    errorCallback: errorCallback)
    }

    func new(todo:AgendaItem,
             doneCallback: @escaping ((AgendaItem) -> ()),
             errorCallback: ((Error) -> ())? = nil) {
        communicate(uri: "/todo/new",
                    requestType: "POST",
                    body: todo,
                    doneCallback: doneCallback,
                    errorCallback: errorCallback)
    }

    func update(todo:AgendaItem,
                doneCallback: @escaping ((AgendaItem) -> ()),
                errorCallback: ((Error) -> ())? = nil) {
        communicate(uri: "/todo/\(todo._id)",
                    requestType: "PUT",
                    body: todo,
                    doneCallback: doneCallback,
                    errorCallback: errorCallback)
    }

    func delete(todo:AgendaItem,
                doneCallback: @escaping (([String: String]) -> ()),
                errorCallback: ((Error) -> ())? = nil) {
        communicate(uri: "/todo/\(todo._id)",
                    requestType: "DELETE",
                    body: todo,
                    doneCallback: doneCallback,
                    errorCallback: errorCallback)
    }
    
    func forward(todo:AgendaItem,
                 doneCallback: @escaping (([String: String]) -> ()),
                 errorCallback: ((Error) -> ())? = nil) {
        communicate(uri: "/todo/\(todo._id)/forward",
                    requestType: "POST",
                    body: todo,
                    doneCallback: doneCallback,
                    errorCallback: errorCallback)
    }
    
    // GENERIC COMMUNICATION ENGINE ============================================
    
    func communicate<S: Encodable,
                     T: Decodable>(uri: String,
                                   requestType: String,
                                   body: S? = nil,
                                   doneCallback: @escaping ((T) -> ()),
                                   errorCallback: ((Error) -> ())? = nil) {
        // Prepare URL
        let url = URL(string: uri, relativeTo: baseURL)
        guard let requestUrl = url else { fatalError() }

        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = requestType

        do {
            if requestType == "POST" || requestType == "PUT" {
                if let body = body {
                    request.httpBody = try JSONEncoder().encode(body)
                }
            }
        } catch let error {
            return errorCallback?(error) ?? ()
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = session.dataTask(with: request) { (data, response, error) in
           if let error = error {
               return errorCallback?(error) ?? ()
           }
           
           guard let data = data else {
               return errorCallback?(ServerCommsError.noDataReceived) ?? ()
           }
           
            if let httpResponse = response as? HTTPURLResponse {
                do {
                    if httpResponse.statusCode >= 400 {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: String] {
                            let errorMsg = json["msg"] ?? "Unknown reply"
                            return errorCallback?(ServerCommsError.remoteError(errorMsg)) ?? ()
                        } else {
                            let error = ServerCommsError.unknownRemoteError(httpResponse.statusCode)
                            return errorCallback?(error) ?? ()
                        }
                    } else {
                        return doneCallback(try JSONDecoder().decode(T.self, from: data))
                    }
                } catch let deserError {
                    return errorCallback?(deserError) ?? ()
                }
            } else {
                return errorCallback?(ServerCommsError.noURLResponse) ?? ()
            }
        }

        task.resume()
    }
}
