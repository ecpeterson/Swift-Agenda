//
//  DumbLoader.swift
//  Agenda
//
//  Created by Eric Peterson on 10/7/20.
//  Borrowed from https://developer.apple.com/tutorials/swiftui/building-lists-and-navigation
//

import UIKit
import SwiftUI
import CoreLocation

let agendaData: [AgendaItem] = load("dummyAgenda.json")

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
