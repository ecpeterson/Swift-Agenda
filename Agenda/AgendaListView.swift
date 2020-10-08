//
//  AgendaListView.swift
//  Agenda
//
//  Created by Eric Peterson on 10/6/20.
//

import SwiftUI

struct AgendaListBlockView: View {
    var dateOnly: DateOnly
    var agendaMiniList: [AgendaItem]
    var refreshHook: (() -> ())
    
    let header: Text
    
    init(dateOnly: DateOnly,
         agendaMiniList: [AgendaItem],
         refreshHook: @escaping () -> ()) {
        self.dateOnly = dateOnly
        self.agendaMiniList = agendaMiniList
        self.refreshHook = refreshHook
        
        self.header = dateOnly == DateOnly() ?
            Text("\(Date(dateOnly: dateOnly).localizedDescription) - Today's Date").bold() :
            Text(Date(dateOnly: dateOnly).localizedDescription)
    }
    
    var body: some View {
        Section(header: header) {
            ForEach(agendaMiniList, id: \.id) {
                agendaItem in
                NavigationLink(destination: AgendaDetailEditView(item: agendaItem)) {
                    AgendaRowView(item: agendaItem, onUpdate: refreshHook)
                }
            }.onDelete(perform: deleteFunc)
        }
    }
    
    func deleteFunc(at indexSet: IndexSet) {
        // TODO: implement delete call
        for index in indexSet {
            print(agendaMiniList[index].id)
        }
        
        return refreshHook()
    }
}

struct AgendaListView: View {
    var agendaList = agendaData
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupByDate(agendaItems: agendaList),
                        id: \.0) {
                    (dateOnly, agendaMiniList) in
                    AgendaListBlockView(dateOnly: dateOnly,
                                        agendaMiniList: agendaMiniList,
                                        refreshHook: refreshList)
                }
            }
            .navigationBarItems(trailing: NavigationLink(destination: AgendaDetailNewView()) {
                    Image(systemName: "plus")
            })
            .navigationBarTitle(Text("Agenda"))
        }.onAppear(perform: refreshList)
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
