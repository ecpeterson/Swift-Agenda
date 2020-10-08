//
//  AgendaDetailView.swift
//  Agenda
//
//  Created by Eric Peterson on 10/7/20.
//

import SwiftUI
import Combine

struct AgendaDetailView: View {
    @State var item: AgendaItem
    @State var localDate: Date
    
    init(item: AgendaItem) {
        self._item = .init(initialValue: item)
        self._localDate = .init(initialValue: Date(dateOnly: item.date))
    }
    
    var body: some View {
        VStack {
            TextField("To-do item", text: $item.text)
            Toggle("Completed", isOn: $item.complete_p)
            
            Divider()
            
            DatePicker("Date", selection: $localDate,
                       displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
            
            HStack {
                Text("Days until urgent:")
                
                TextField("", value: $item.priority,
                          formatter: NumberFormatter())
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
            }
            
            Divider()
            
            HStack {
                Text("Repeat every")
                
                TextField("", value: $item.frequency,
                          formatter: NumberFormatter())
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
            }
            
            HStack {
                // TODO: show selection, then click text to reveal picker
                Picker("Repeat", selection: $item.repeat_p) {
                    Text("Never").tag(RepeatT.never)
                    Text("Days").tag(RepeatT.daily)
                    Text("Weeks").tag(RepeatT.weekly)
                    Text("Months").tag(RepeatT.monthly)
                    Text("Years").tag(RepeatT.yearly)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
}

struct AgendaDetailEditView: View {
    @State var item: AgendaItem
    
    var body: some View {
        VStack {
            AgendaDetailView(item: item)
            Spacer()
            HStack {
                Spacer()
                Button(action: forward) {
                    Image(systemName: "goforward")
                }
                Spacer()
                Button(action: delete) {
                    Image(systemName: "trash")
                }
            }
        }
        .padding()
        .navigationBarTitle(Text("Item details"), displayMode: .inline)
    }
    
    func delete() {
        // send delete message to server
        // navigate up from this screen
        return
    }
    
    func forward() {
        // send forward message to server
        // navigate up from this screen
        return
    }
}

struct AgendaDetailNewView: View {
    @State var item: AgendaItem = AgendaItem()
    
    var body: some View {
        VStack {
            AgendaDetailView(item: item)
            Spacer()
            HStack {
                Spacer()
                Button(action: delete) {
                    Image(systemName: "trash")
                }
            }
        }
        .padding()
        .navigationBarTitle(Text("New item"), displayMode: .inline)
    }
    
    func delete() {
        // send delete message to server
        // navigate up from this screen
        return
    }
}

struct AgendaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AgendaDetailView(item: agendaData[0])
    }
}
