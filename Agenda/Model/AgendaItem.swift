//
//  AgendaItem.swift
//  Agenda
//
//  Created by Eric Peterson on 10/7/20.
//

import Foundation
import SwiftUI

struct AgendaItem: Codable {
    var text: String = ""
    var complete_p: Bool = false
    var repeat_p: RepeatT = .never
    var frequency: Int = 1
    var date: DateOnly = DateOnly()
    var priority: Int = 2
    var id: String = "defaultId"
}

enum RepeatT: String, Codable {
    case daily
    case weekly
    case monthly
    case yearly
    case never
}

extension Formatter {
    static let date = DateFormatter()
}

extension Date {
    func localizedDescription(dateStyle: DateFormatter.Style = .short,
                              timeStyle: DateFormatter.Style = .none,
                           in timeZone : TimeZone = .current,
                              locale   : Locale = .current) -> String {
        Formatter.date.locale = locale
        Formatter.date.timeZone = timeZone
        Formatter.date.dateStyle = dateStyle
        Formatter.date.timeStyle = timeStyle
        return Formatter.date.string(from: self)
    }
    var localizedDescription: String { localizedDescription() }
}

// expects agendaItems to be date-sorted
func groupByDate(agendaItems: [AgendaItem]) -> [(DateOnly, [AgendaItem])] {
    var buckets: [(DateOnly, [AgendaItem])] = []
    var this_bucket: [AgendaItem] = []
    var this_date: DateOnly = DateOnly()
    let now = DateOnly()
    
    func dump_bucket() {
        if this_bucket.count != 0 || this_date == now {
            buckets.append((this_date, this_bucket))
        }
        this_bucket = []
    }
    
    for item in agendaItems {
        // if we're about to trip the odometer...
        if item.date != this_date {
            dump_bucket()
            if this_date < now && item.date > now {
                this_date = now
            } else {
                this_date = item.date
            }
        }
        
        this_bucket.append(item)
    }
    
    dump_bucket()
    
    return buckets
}

/*
 http://www.globalnerdy.com/2020/05/28/how-to-work-with-dates-and-times-in-swift-5-part-3-date-arithmetic/
 // What was the date 5 weeks ago?
 let fiveWeeksAgo = userCalendar.date(byAdding: .weekOfYear, value: -5, to: Date())!
 print("5 weeks ago was: \(fiveWeeksAgo.description(with: Locale(
 */
