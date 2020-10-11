//
//  DateOnly.swift
//  Agenda
//
//  Created by Eric Peterson on 10/8/20.
//

import Foundation

struct DateOnly: Hashable {
    var year: Int
    var month: Int
    var day: Int
    
    init() {
        self.init(date: Date())
    }
    
    init(date: Date) {
        let calendar = Calendar(identifier: .gregorian)
        let ymd = calendar.dateComponents([.year, .month, .day], from: date)
        self.year = ymd.year!
        self.month = ymd.month!
        self.day = ymd.day!
    }
    
    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }
    
    func int() -> Int {
        return (self.year * 15 + self.month) * 35 + self.day
    }
}

extension DateOnly: Comparable {
    static func < (lhs: DateOnly, rhs: DateOnly) -> Bool {
        return lhs.int() <  rhs.int()
    }
    
    static func == (lhs: DateOnly, rhs: DateOnly) -> Bool {
        return lhs.int() == rhs.int()
    }
}

extension DateOnly: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.int())
    }
    
    init(from decoder: Decoder) throws {
        let int = try decoder.singleValueContainer().decode(Int.self)
        let day = int % 35
        let month = ((int - day) / 35) % 15
        let year = (int - day - 35 * month) / (35 * 15)
        self.init(year: year, month: month, day: day)
    }
}

extension Date {
    init(dateOnly: DateOnly) {
        let components = DateComponents(calendar: Calendar.current,
                                        year: dateOnly.year,
                                        month: dateOnly.month,
                                        day: dateOnly.day)
        self.init(timeInterval: 0, since: components.date!)
    }
}
