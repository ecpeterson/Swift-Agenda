//
//  RowView.swift
//  Agenda
//
//  Created by Eric Peterson on 10/6/20.
//

import SwiftUI

// from https://swiftui-lab.com/custom-styling/
struct MyToggleStyle: ToggleStyle {
    let width: CGFloat = 70
    var onColor: Color = Color.blue
    var offColor: Color = Color.gray
    
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            configuration.label
            
            Spacer()

            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: width/2)
                    .frame(width: width, height: width / 2)
                    .foregroundColor(configuration.isOn ? self.onColor : self.offColor)
                
                RoundedRectangle(cornerRadius: width/2)
                    .frame(width: (width / 2) - 6, height: width / 2 - 6)
                    .padding(4)
                    .foregroundColor(.white)
                    // this used to display days 'til due,
                    // + for > 7, " " for no due date, x for done
                    .onTapGesture {
                        withAnimation {
                            configuration.$isOn.wrappedValue.toggle()
                    }
                }
            }
        }
    }
}

struct AgendaRowView: View {
    @EnvironmentObject var settings: UserSettings
    @State var item: AgendaItem
    var onUpdate: (() -> ())?
    
    func alertColor() -> Color {
        if self.item.priority <= 0 {
            return Color.gray
        }
        
        let calendar = Calendar.current
        let current_date = Date()
        let days_til_due = calendar.dateComponents(
            [.day],
            from: current_date, to:Date(dateOnly: self.item.date)).day!
        
        if days_til_due < 0 {
            return Color.purple
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
        Toggle(item.text, isOn: toggleBinding)
            .toggleStyle(MyToggleStyle(offColor: self.alertColor()))
        // TODO: toggle click needs to send an edit update and cause a refresh
    }
}

struct AgendaRowView_Previews: PreviewProvider {
    static var previews: some View {
        AgendaRowView(item: agendaData[0])
    }
}
