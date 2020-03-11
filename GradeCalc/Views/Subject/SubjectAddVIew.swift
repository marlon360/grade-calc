//
//  SemesterAddVIew.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 08.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

struct SubjectAddView: View {
    
    @State private var title = ""
    @State private var grade = "1"
    @State private var active = true
    @State private var simulation = false
    @State private var simMin = "1.0"
    @State private var simMax = "4.0"
    @State private var weight = "1.0"
    
    @State private var selectedSemester = 0
    @State private var gradeCounts = true
    
    @State private var isShowingNewSemester = false
    @State private var newSemester = ""
    
    @Binding var isPresented: Bool
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Semester.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Semester.title, ascending: true)]) var semesters: FetchedResults<Semester>
    
    @State private var semesterChooser = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section() {
                    TextField("Titel", text: self.$title)
                }
                                
                Section() {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Note:")
                            TextField("Note", text: self.$grade)
                        }
                        .padding(.top, 5)
//                        .padding(.bottom, 2)
                       Divider()
                        .offset(x: 0, y: 10)
                        
                    }
                    HStack {
                        Text("Gewichtung:")
                        TextField("Gewichtung", text: self.$weight)
                    }
                }
                
                Section(header: Text("Gewichtung")) {
                    VStack(spacing: 0) {
                        Toggle(isOn: self.$gradeCounts) {
                            Text("Note zählt")
                        }
                       Divider()
                        .offset(x: 0, y: 10)
                        
                    }
                    HStack {
                        Text("Gewichtung:")
                        if (self.gradeCounts) {
                            TextField("Gewichtung", text: self.$weight)
                        } else {
                            Text("0")
                        }
                    }
                    .disabled(!self.gradeCounts)
                    .foregroundColor(self.gradeCounts ? Color.black : Color.gray)
                }
                                
                Section(header: Text("Semester")) {
                    Picker(selection: $semesterChooser, label: Text("Semester")) {
                        Text("Semester wählen").tag(0)
                        Text("Neues Semester").tag(1)
                    }.pickerStyle(SegmentedPickerStyle())
                        .onAppear {
                            if (self.semesters.count == 0) {
                                self.semesterChooser = 1
                            }
                        }
                    
                    if (semesterChooser == 0) {
                        if (semesters.count > 0) {
                            Picker(selection: $selectedSemester, label: Text("Semester")) {
                                ForEach(0 ..< semesters.count) {
                                    Text(self.semesters[$0].title ?? "Semester").tag($0)

                                }
                            }
                        } else {
                            Text("Keine Semester vorhanden")
                        }
                    }
                    
                    if (semesterChooser == 1) {
                        TextField("Neues Semester", text: self.$newSemester)
                    }
                    
                }
                
                Section() {
                    Button(action: {
                        self.saveSubject()
                        self.isPresented = false
                    }) {
                        Text("Speichern")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                
            }
            .navigationBarTitle(Text("Neue Note"), displayMode: .inline)
            .navigationBarItems(leading:
                Button(action: {
                    self.isPresented = false
                }) {
                    Text("Abbrechen")
                }
            )
        }
    }
    
    func saveSubject() {
        let subject = Subject(context: self.managedObjectContext)
        subject.title = self.title
        subject.active = true
        subject.simulation = false
        subject.simMin = Float(self.simMin) ?? Float(1)
        subject.simMax = Float(self.simMax) ?? Float(4)
        subject.weight = Float(self.weight) ?? Float(1)
        subject.grade = Float(self.grade) ?? Float(1)
        
        var semester: Semester
        if (self.semesterChooser == 0) {
            semester = self.semesters[self.selectedSemester]
        } else {
            semester = Semester(context: self.managedObjectContext)
            semester.title = self.newSemester
        }
        
        subject.semester = semester
        
        semester.addToSubjects(subject)
        
        do {
            print(subject.grade)
            try self.managedObjectContext.save()
        } catch {
            print(error)
        }
        
    }
    
}
