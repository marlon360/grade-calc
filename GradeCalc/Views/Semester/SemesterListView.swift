//
//  SemesterListView.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 08.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

struct SemesterListView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Semester.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Semester.title, ascending: true)]) var semesters: FetchedResults<Semester>
    
    @State var addSheetVisible = false
    
    @State private var refreshing = false
    private var didSave =  NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
    
    init() {
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().backgroundColor = UIColor(named: "BlueBackground")
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(self.semesters) { semester in
                        NavigationLink(destination: SubjectListView(semester: semester)) {
                            SemesterCellView(semester: semester)
                            .contextMenu {
                                Button(action: {
                                    // change country setting
                                }) {
                                    Text("Edit")
                                    Image(systemName: "pencil")
                                }

                                Button(action: {
                                    self.removeSemester(semester: semester)
                                }) {
                                    Text("Delete")
                                        .foregroundColor(.red)
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .onReceive(self.didSave) { _ in
                            self.refreshing.toggle()
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color(.lightGray), radius: 1.4, x: 0, y: 1)
                        .listRowBackground(Color(UIColor(named: "BlueBackground") ?? .blue))
                    }
                    .onDelete(perform: removeSemester)
                }
                Text(self.refreshing ? "" : "")
                GradeAverageView(semesters: semesters)
            }
            .navigationBarItems(leading: EditButton(), trailing:
                Button(action: {
                    self.addSheetVisible = true
                }) {
                    Image(systemName: "plus")
                    .imageScale(.large)
                }
            )
            .navigationBarTitle("Semester")
        }.sheet(isPresented: $addSheetVisible) {
            SemesterAddiew(isPresented: self.$addSheetVisible)
                .environment(\.managedObjectContext, self.managedObjectContext)
        }
    }
    
   func removeSemester(at offsets: IndexSet) {
        for index in offsets {
            let semester = semesters[index]
            removeSemester(semester: semester)
        }
    }
    
    func removeSemester(semester: Semester) {
        managedObjectContext.delete(semester)
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
    }
    
}
