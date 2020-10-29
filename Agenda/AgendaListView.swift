//
//  AgendaListView.swift
//  Agenda
//
//  Created by Eric Peterson on 10/6/20.
//

import SwiftUI


// https://medium.com/stepup-development/handling-multiple-sheets-in-swiftui-2e9a73d99cd7
// TODO: compute showSheet from sheetDestination
class SheetNavigator: ObservableObject {
    @Published var showSheet = false
    var sheetDestination: SheetDestination = .none
    
    enum SheetDestination {
        case none
        case new
        case edit(AgendaItem)
    }
    
    func sheetView() -> AnyView {
        switch sheetDestination {
        case .none:
            return Text("None")
                .eraseToAnyView()
        case .new:
            return AgendaDetailNewView()
                .eraseToAnyView()
        case .edit(let agendaItem):
            return AgendaDetailEditView(item: agendaItem)
                .eraseToAnyView()
        }
    }
}


extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}


struct AgendaListBlockView: View {
    @EnvironmentObject var settings: UserSettings
    
    var dateOnly: DateOnly
    var agendaMiniList: [AgendaItem]
    var refreshHook: (() -> ())
    @ObservedObject var sheetNavigator: SheetNavigator
    
    #if os(iOS)
    let sectionPadding: CGFloat = -10
    #else
    let sectionPadding: CGFloat = 0
    #endif
    
    let header: Text
    
    init(dateOnly: DateOnly,
         agendaMiniList: [AgendaItem],
         refreshHook: @escaping () -> (),
         sheetNavigator: SheetNavigator) {
        self.dateOnly = dateOnly
        self.agendaMiniList = agendaMiniList
        self.refreshHook = refreshHook
        self.sheetNavigator = sheetNavigator
        
        self.header = dateOnly == DateOnly() ?
            Text("\(Date(dateOnly: dateOnly).localizedDescription) - Today's Date").bold() :
            Text(Date(dateOnly: dateOnly).localizedDescription)
    }
    
    var body: some View {
        Section(header: header) {
            ForEach(agendaMiniList, id: \.self) {
                agendaItem in
                AgendaRowView(item: agendaItem, onUpdate: refreshHook)
                    .padding(.vertical, 0)
                    .onTapGesture(perform: {
                        self.sheetNavigator.sheetDestination = .edit(agendaItem)
                        self.sheetNavigator.showSheet = true
                    })
            }
            .onDelete(perform: deleteFunc)
        }
        .padding(.vertical, sectionPadding)
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
    @ObservedObject var sheetNavigator = SheetNavigator()
    
    #if os(iOS)
    let groupedListStyle = GroupedListStyle()
    #else
    let groupedListStyle = DefaultListStyle()
    #endif
    
    var addButton: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(
                    action: {
                        self.sheetNavigator.sheetDestination = .new
                        self.sheetNavigator.showSheet = true
                    },
                    label: {
                        Text("+")
                            .font(.system(.largeTitle))
                            .frame(width: 77, height: 70)
                            .foregroundColor(Color.white)
                            .padding(.bottom, 7)
                    })
                        .buttonStyle(BorderlessButtonStyle())
                        .background(Color.blue)
                        .cornerRadius(38.5)
                        .padding()
                        .shadow(color: Color.black.opacity(0.3),
                                radius: 3,
                                x: 3,
                                y: 3)
            }
        }
    }
    
    var body: some View {
        let internalView =
            ZStack {
                List {
                    ForEach(groupByDate(agendaItems: agendaList),
                            id: \.0) {
                        (dateOnly, agendaMiniList) in
                        AgendaListBlockView(dateOnly: dateOnly,
                                            agendaMiniList: agendaMiniList,
                                            refreshHook: self.refreshList,
                                            sheetNavigator: self.sheetNavigator)
                            .listStyle(groupedListStyle)
                    }
                }
                .navigationBarTitle(Text("Agenda"), displayMode: .inline)
                .onAppear(perform: refreshList)
                
                /* "Add New" plus button */
                self.addButton
            }
            .sheet(isPresented: self.$sheetNavigator.showSheet) {
                self.sheetNavigator.sheetView()
                    .environmentObject(settings)
            }
            .onReceive(self.sheetNavigator.objectWillChange) { _ in
                refreshList()
            }
        
        #if os(iOS)
        return internalView
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            refreshList()
        }
        #else
        // TODO: figure out how to refresh macOS on raise
        return internalView
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.willBecomeActiveNotification)) { _ in
            refreshList()
        }
        #endif
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
    
    // https://stackoverflow.com/a/49074543/464405 for regular refreshes
}

struct AgendaListView_Previews: PreviewProvider {
    static var previews: some View {
        AgendaListView(agendaList: agendaData)
            .environmentObject(UserSettings())
    }
}
