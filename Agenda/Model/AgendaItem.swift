//
//  AgendaItem.swift
//  Agenda
//
//  Created by Eric Peterson on 10/7/20.
//

import Foundation
import SwiftUI

struct AgendaItem: Hashable, Codable {
    var text: String = ""
    var complete_p: Bool = false
    var repeat_p: RepeatT = .never
    var frequency: Int = 1
    var date: DateOnly = DateOnly()
    var priority: Int = 2
    var _id: String = "defaultId"
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
// TODO: this doesn't emit a today bucket in the case of an empty list
func groupByDate(agendaItems: [AgendaItem]) -> [(DateOnly, [AgendaItem])] {
    var buckets: [(DateOnly, [AgendaItem])] = []
    var this_bucket: [AgendaItem] = []
    var this_date: DateOnly = DateOnly()
    let now = DateOnly()
    
    func dump_bucket(next_date: DateOnly?) {
        if this_bucket.count != 0 {
            buckets.append((this_date, this_bucket))
        } else if (this_date == now) && ((next_date == nil) || (next_date! > this_date)) {
            buckets.append((this_date, this_bucket))
        }
        this_bucket = []
    }
    
    for item in agendaItems {
        // if we're about to trip the odometer...
        if item.date != this_date {
            dump_bucket(next_date: item.date)
            if this_date < now && item.date > now {
                this_date = now
                dump_bucket(next_date: item.date)
                this_date = item.date
            } else {
                this_date = item.date
            }
        }
        
        this_bucket.append(item)
    }
    
    if (this_date < now) {
        dump_bucket(next_date: now)
        this_date = now
    }
    
    dump_bucket(next_date: nil)
    
    return buckets
}
