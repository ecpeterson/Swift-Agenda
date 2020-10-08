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
    var date: Date = Date()
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

// expects agendaItems to be date-sorted
func groupByDate(agendaItems: [AgendaItem]) -> [(Date, [AgendaItem])] {
    var buckets: [(Date, [AgendaItem])] = []
    var this_bucket: [AgendaItem] = []
    var this_date: Date = Date()
    
    for item in agendaItems {
        // if we're about to trip the odometer...
        if item.date != this_date {
            // dump out the old bucket
            if this_bucket.count != 0 {
                buckets.append((this_date, this_bucket))
                this_bucket = []
            }
            
            this_date = item.date
        }
        
        this_bucket.append(item)
    }
    
    if this_bucket.count != 0 {
        buckets.append((this_date, this_bucket))
    }
    
    return buckets
}

/*
 http://www.globalnerdy.com/2020/05/28/how-to-work-with-dates-and-times-in-swift-5-part-3-date-arithmetic/
 // What was the date 5 weeks ago?
 let fiveWeeksAgo = userCalendar.date(byAdding: .weekOfYear, value: -5, to: Date())!
 print("5 weeks ago was: \(fiveWeeksAgo.description(with: Locale(
 */
