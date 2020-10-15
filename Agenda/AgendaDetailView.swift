//
//  AgendaDetailView.swift
//  Agenda
//
//  Created by Eric Peterson on 10/7/20.
//

import SwiftUI
import Combine

// from https://stackoverflow.com/a/63967389/464405
struct IntField: View {
    @Binding var int: Int
    @State private var intString: String  = ""
    var body: some View {
        return TextField("", text: $intString)
            .onReceive(Just(intString)) { value in
                if let i = Int(value) { int = i }
                else { intString = "\(int)" }
            }
            .onAppear(perform: {
                intString = "\(int)"
            })
            .multilineTextAlignment(.trailing)
    }
}

struct AgendaDetailView: View {
    let stepperMax = 1000
    @Binding var item: AgendaItem
    
    func repeat_str() -> String {
        switch(item.repeat_p) {
        case .daily:
            return (item.frequency > 1 ? "\(item.frequency) " : "") + "day" + (item.frequency > 1 ? "s" : "")
        case .weekly:
            return (item.frequency > 1 ? "\(item.frequency) " : "") + "week" + (item.frequency > 1 ? "s" : "")
        case .monthly:
            return (item.frequency > 1 ? "\(item.frequency) " : "") + "month" + (item.frequency > 1 ? "s" : "")
        case .yearly:
            return (item.frequency > 1 ? "\(item.frequency) " : "") + "year" + (item.frequency > 1 ? "s" : "")
        case .never:
            return "never"
        }
    }
    
    var body: some View {
        let localDate = Binding<Date>(get: {
            Date(dateOnly: self.item.date)
        }, set: { newValue in
            self.item.date = DateOnly(date: newValue)
        })
        
        VStack {
            TextField("To-do item", text: $item.text)
            Toggle("Completed", isOn: $item.complete_p)
            
            Divider()
            
            DatePicker("Date", selection: localDate,
                       displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
            
            HStack {
                Stepper(value: $item.priority, in: 0...stepperMax) {
                    Text("Days until urgent: \(item.priority)")
                }
//                IntField(int: $item.priority)
            }
            
            Divider()
            
            HStack {
                Stepper(value: $item.frequency, in: 1...stepperMax) {
                    Text("Repeat every: " + repeat_str())
                }
//                IntField(int: $item.frequency)
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
    @EnvironmentObject var settings: UserSettings
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            AgendaDetailView(item: $item)
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
        .navigationBarItems(trailing: Button("Confirm", action: update))
    }
    
    func delete() {
        settings.cxn.delete(
            todo: item,
            doneCallback: { _ in
                DispatchQueue.main.async {
                    self.presentationMode.wrappedValue.dismiss()
                }
            })
    }
    
    func forward() {
        settings.cxn.forward(
            todo: item,
            doneCallback: { _ in
                DispatchQueue.main.async {
                    self.presentationMode.wrappedValue.dismiss()
                }
            })
    }
    
    func update() {
        settings.cxn.update(
            todo: item,
            doneCallback: { _ in
                DispatchQueue.main.async {
                    self.presentationMode.wrappedValue.dismiss()
                }
            })
    }
}

struct AgendaDetailNewView: View {
    @State var item: AgendaItem = AgendaItem()
    @EnvironmentObject var settings: UserSettings
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            AgendaDetailView(item: $item)
            Spacer()
        }
            .padding()
            .navigationBarTitle(Text("New item"), displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Confirm", action: commit))
    }
    
    func commit() {
        settings.cxn.new(
            todo: item,
            doneCallback: { _ in
                DispatchQueue.main.async {
                    self.presentationMode.wrappedValue.dismiss()
                }
            })
    }
}

struct AgendaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AgendaDetailView(item: .constant(agendaData[0]))
            .environmentObject(UserSettings())
    }
}
