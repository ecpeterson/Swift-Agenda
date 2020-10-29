//
//  RowView.swift
//  Agenda
//
//  Created by Eric Peterson on 10/6/20.
//

import SwiftUI

// from https://swiftui-lab.com/custom-styling/
struct MyToggleStyle: ToggleStyle {
    let width: CGFloat = 50
    var onColor: Color = Color.blue
    var offColor: Color = Color.gray
    let onSigil: String = "⨉"
    var offSigil: String = "⨉"
    
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            ZStack {
                Text("⬜️")
                    .colorMultiply(configuration.isOn ?
                        onColor : offColor)
                Text(configuration.isOn ? onSigil : offSigil)
            }
            .foregroundColor(.white)
            .onTapGesture {
                withAnimation {
                    configuration.$isOn.wrappedValue.toggle()
                }
            }
            
            configuration.label
            
            Spacer()
        }
    }
}

struct AgendaRowView: View {
    @EnvironmentObject var settings: UserSettings
    @State var item: AgendaItem
    var onUpdate: (() -> ())?
    
    func alertColor() -> Color {
        let calendar = Calendar.current
        let current_date = Date(dateOnly: DateOnly(date: Date()))
        let days_til_due = calendar.dateComponents(
            [.day],
            from: current_date, to:Date(dateOnly: self.item.date)).day!
        
        if days_til_due < 0 {
            return Color.purple
        }
        
        if self.item.priority <= 0 {
            return Color.gray
        }
        
        if days_til_due < self.item.priority {
            return Color.red
        }
        
        if days_til_due < 2 * self.item.priority {
            return Color.yellow
        }
        
        if days_til_due < 4 * self.item.priority {
            return Color.green
        }
        
        return Color.gray
    }
    
    func alertSigil() -> String {
        let calendar = Calendar.current
        let current_date = Date(dateOnly: DateOnly(date: Date()))
        let components = calendar.dateComponents(
            [.day],
            from: current_date, to:Date(dateOnly: self.item.date))
        let days_til_due = components.day!
                
        if days_til_due >= 4 * self.item.priority {
            return " "
        }
        
        if days_til_due > 7 {
            return "+"
        }
        
        if 0 <= days_til_due && days_til_due <= 7 {
            return "\(days_til_due)"
        }
        
        return "!"
    }
    
    var body: some View {
        let toggleBinding = Binding<Bool>(get: {
            self.item.complete_p
        }, set: { newValue in
            self.item.complete_p = newValue
            settings.cxn.update(
                todo: item,
                doneCallback: { _ in
                    if let unwrapFunc = onUpdate {
                        unwrapFunc()
                    }
                })
        })
        
        // use .contextMenu for actions?
        return Toggle(item.text, isOn: toggleBinding)
            .toggleStyle(MyToggleStyle(offColor: self.alertColor(),
                                       offSigil: self.alertSigil()))
    }
}

struct AgendaRowView_Previews: PreviewProvider {
    static var previews: some View {
        AgendaRowView(item: agendaData[0])
    }
}
