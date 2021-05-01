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
    
    #if os(iOS)
    let repeatPickerStyle = SegmentedPickerStyle()
    let datePickerStyle = CompactDatePickerStyle()
    let pickerPadding: CGFloat = 0
    #else
    let repeatPickerStyle = DefaultPickerStyle()
    let datePickerStyle = DefaultDatePickerStyle()
    let pickerPadding: CGFloat = -10
    #endif
    
    func repeat_str() -> String {
        switch(item.repeat_p) {
        case .daily:
            return "\(item.frequency) day" + (item.frequency > 1 ? "s" : "")
        case .weekly:
            return "\(item.frequency) week" + (item.frequency > 1 ? "s" : "")
        case .monthly:
            return "\(item.frequency) month" + (item.frequency > 1 ? "s" : "")
        case .yearly:
            return "\(item.frequency) year" + (item.frequency > 1 ? "s" : "")
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
        
        return Form {
            Section {
                TextField("To-do item", text: $item.text)
                Toggle("Completed", isOn: $item.complete_p)
            }
            
            Section {
                HStack {
                    DatePicker("Date", selection: localDate,
                               displayedComponents: .date)
                        .datePickerStyle(datePickerStyle)
                }
                
                HStack {
                    #if os(iOS)
                    Text("\(item.priority) days 'til urgent")
                    #endif
                    Stepper("", value: $item.priority, in: 0...stepperMax)
                        .padding(.top, pickerPadding)
                    #if os(macOS)
                    Text("\(item.priority) days until urgent")
                    #endif
                }
            }
            
            Section {
                HStack {
                    #if os(macOS)
                    Text("Repeat every")
                    #else
                    Text("Every \(repeat_str())")
                    #endif
                    Stepper("", value: $item.frequency, in: 1...stepperMax)
                        .padding(.top, pickerPadding)
                    #if os(macOS)
                    Text(repeat_str())
                    #endif
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
                    .pickerStyle(repeatPickerStyle)
                }
            }
        }
    }
}

#if os(macOS)
enum DisplayModeEnum {
    case inline
}

extension View {
    func navigationBarTitle(_ title: Text,
                            displayMode: DisplayModeEnum) -> some View {
        self
    }
}
#endif

struct AgendaDetailEditView: View {
    @State var item: AgendaItem
    @EnvironmentObject var settings: UserSettings
    @Environment(\.presentationMode) var presentationMode
    
    #if os(iOS)
    var body: some View {
        NavigationView {
            VStack {
                AgendaDetailView(item: $item)
                Spacer()
                HStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                    Spacer()
                    Button(action: delete) {
                        Image(systemName: "trash")
                    }
                    Spacer()
                    Button(action: forward) {
                        Image(systemName: "goforward")
                    }
                    Spacer()
                    Button(action: update) {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .padding()
            .navigationBarTitle(Text("Item details"), displayMode: .inline)
        }
    }
    #else
    var body: some View {
        VStack {
            AgendaDetailView(item: $item)
            Spacer()
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                }
                Spacer()
                Button(action: delete) {
                    Text("Delete")
                }
                Spacer()
                Button(action: forward) {
                    Text("Forward")
                }
                Spacer()
                Button(action: update) {
                    Text("Confirm")
                }
            }
        }
        .padding()
    }
    #endif
    
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
    
    #if os(iOS)
    var body: some View {
        NavigationView {
            VStack {
                AgendaDetailView(item: $item)
                Spacer()
                HStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                    Spacer()
                    Button(action: commit) {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .padding()
            .navigationBarTitle(Text("New item"), displayMode: .inline)
        }
    }
    #else
    var body: some View {
        VStack {
            AgendaDetailView(item: $item)
            Spacer()
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                }
                Spacer()
                Button(action: commit) {
                    Text("Confirm")
                }
            }
        }.padding()
    }
    #endif
    
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
        AgendaDetailEditView(item: agendaData[0])
            .environmentObject(UserSettings())
    }
}
