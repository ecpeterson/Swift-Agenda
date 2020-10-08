//
//  AgendaListView.swift
//  Agenda
//
//  Created by Eric Peterson on 10/6/20.
//

import SwiftUI

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

struct AgendaListView: View {
    var agendaList = agendaData
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupByDate(agendaItems: agendaList),
                        id: \.0) {
                    (date, agendaMiniList) in
                    Section(header: Text(date.localizedDescription)) {
                        ForEach(agendaMiniList, id: \.id) {
                            agendaItem in
                            NavigationLink(destination: AgendaDetailEditView(item: agendaItem)) {
                                AgendaRowView(item: agendaItem, onUpdate: self.refreshList)
                            }
                        }.onDelete(perform: { deleteFunc(at: $0, in: agendaMiniList) })
                    }
                }
            }
            .navigationBarItems(trailing: NavigationLink(destination: AgendaDetailNewView()) {
                    Image(systemName: "plus")
            })
            .navigationBarTitle(Text("Agenda"))
        }.onAppear(perform: refreshList)
    }
    
    func deleteFunc(at indexSet: IndexSet, in largerList: [AgendaItem]) {
        // TODO: implement delete call
        for index in indexSet {
            print(largerList[index].id)
        }
        
        return refreshList()
    }
    
    func addNew() {
        // TODO: switch to a New Item panel
    }
    
    func refreshList() {
        // TODO: refresh the local data
    }
}

struct AgendaListView_Previews: PreviewProvider {
    static var previews: some View {
        AgendaListView()
    }
}
