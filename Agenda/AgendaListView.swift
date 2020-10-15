//
//  AgendaListView.swift
//  Agenda
//
//  Created by Eric Peterson on 10/6/20.
//

import SwiftUI

struct AgendaListBlockView: View {
    @EnvironmentObject var settings: UserSettings
    
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
            ForEach(agendaMiniList, id: \._id) {
                agendaItem in
                NavigationLink(destination: AgendaDetailEditView(item: agendaItem)) {
                    AgendaRowView(item: agendaItem, onUpdate: refreshHook)
                }
                .padding(.vertical, -10)
            }.onDelete(perform: deleteFunc)
        }
    }
    
    // TODO: the "delete" is actually a forward, which is the right default
    //       behavior but looks weird in the UI, which says "delete"
    func deleteFunc(at indexSet: IndexSet) {
        for index in indexSet {
            settings.cxn.forward(
                todo: agendaMiniList[index],
                doneCallback: { _ in
                    refreshHook()
                })
        }
    }
}

struct AgendaListView: View {
    @State var agendaList: [AgendaItem] = []
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupByDate(agendaItems: agendaList),
                        id: \.0) {
                    (dateOnly, agendaMiniList) in
                    AgendaListBlockView(dateOnly: dateOnly,
                                        agendaMiniList: agendaMiniList,
                                        refreshHook: self.refreshList)
                        .listStyle(GroupedListStyle())
                }
            }
            .navigationBarItems(trailing: NavigationLink(destination: AgendaDetailNewView()) {
                    Image(systemName: "plus")
            })
            .navigationBarTitle(Text("Agenda"))
            .onAppear(perform: refreshList)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    refreshList()
                }
        }
    }
    
    // NOTE: may not actually refresh existing items
    //       ex: make a pri 2 item expiring today, change its pri to 0
    func refreshList() {
        settings.cxn.refresh(
            doneCallback: {response in
                guard let response = response["todos"] else {
                    return self.refreshList()
                }
                
                let sortedItems = response.sorted(by: { $0.date < $1.date })

                DispatchQueue.main.async {
                    self.agendaList = sortedItems
                }
            })
    }
}

struct AgendaListView_Previews: PreviewProvider {
    static var previews: some View {
        AgendaListView(agendaList: agendaData)
            .environmentObject(UserSettings())
    }
}
