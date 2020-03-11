//
//  SemesterListView.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 08.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

struct SubjectListView: View {
    
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
        VStack {
            GradeAverageView(semesters: semesters)
                .padding(.bottom, -10)
            VStack {
                List {
                    ForEach(self.semesters) { semester in
                        Text(semester.title ?? "Semester")
                            .font(.headline)
                            .listRowBackground(Color(UIColor(named: "BlueBackground") ?? .blue))
                        ForEach(semester.subjectsArray, id: \.title) { subject in
                                SubjectCellView(subject: subject)
                                .contextMenu {
                                    Button(action: {
                                        // change country setting
                                    }) {
                                        Text("Edit")
                                        Image(systemName: "pencil")
                                    }

                                    Button(action: {
                                        self.removeSubject(subject: subject)
                                    }) {
                                        Text("Delete")
                                            .foregroundColor(.red)
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .onDelete{ row in
                                self.removeSubject(semester: semester, offsets: row)
                            }
                            .onReceive(self.didSave) { _ in
                                self.refreshing.toggle()
                            }
                        .listRowBackground(Color(UIColor(named: "BlueBackground") ?? .blue))
                    }
                    
                }
            }
            Button(action: {
                self.addSheetVisible = true
            }) {
                Image(systemName:self.refreshing ? "plus" : "plus")
                .imageScale(.large)
                .padding(20)
            }
        }.sheet(isPresented: $addSheetVisible) {
            SubjectAddView(isPresented: self.$addSheetVisible)
                .environment(\.managedObjectContext, self.managedObjectContext)
        }
    }
    
    func removeSubject(semester: Semester, offsets: IndexSet) {
        for index in offsets {
            let subject = semester.subjectsArray[index]
            removeSubject(subject: subject)
        }
    }
    
    func removeSubject(subject: Subject) {
        if let semester = subject.semester {
            if (semester.subjectsArray.count <= 1) {
                managedObjectContext.delete(semester)
            }
        }
        managedObjectContext.delete(subject)
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
    }
    
}
