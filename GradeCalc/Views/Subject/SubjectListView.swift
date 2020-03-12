//
//  SemesterListView.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 08.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

enum ActiveSheet {
   case add, edit
}

struct SubjectListView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Semester.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Semester.title, ascending: true)]) var semesters: FetchedResults<Semester>
    
    @State var sheetVisible = false
    @State var activeSheet: ActiveSheet = .add
    
    @State var currentSubject: Subject?
    
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
                            Button(action: {
                                self.currentSubject = subject
                                self.activeSheet = .edit
                                self.sheetVisible = true
                            }){
                                SubjectCellView(subject: subject)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                                .contextMenu {
                                    Button(action: {
                                        self.currentSubject = subject
                                        self.activeSheet = .edit
                                        self.sheetVisible = true
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
                self.activeSheet = .add
                self.sheetVisible = true
            }) {
                Image(systemName:self.refreshing ? "plus" : "plus")
                .imageScale(.large)
                .padding(20)
            }
        }
        .sheet(isPresented: $sheetVisible) {
            if self.activeSheet == .edit {
                SubjectAddView(subject: self.currentSubject,isPresented: self.$sheetVisible)
                .environment(\.managedObjectContext, self.managedObjectContext)
            }
            if self.activeSheet == .add {
                SubjectAddView(subject:nil,isPresented: self.$sheetVisible)
                .environment(\.managedObjectContext, self.managedObjectContext)
            }
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