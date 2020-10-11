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
    @Binding var item: AgendaItem
    
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
                Text("Days until urgent:")
                // TODO: this isn't being updated.
                IntField(int: $item.priority)
            }
            
            Divider()
            
            HStack {
                Text("Repeat every")
                // TODO: this isn't being updated.
                IntField(int: $item.frequency)
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
    }
}
