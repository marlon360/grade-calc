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
    
    @State var subject: Subject?
    
    @State var title: String
    @State private var grade: String
    @State private var active: Bool
    @State private var simulation: Bool
    @State private var simMin: String
    @State private var simMax: String
    @State private var weight: String
    
    @State private var selectedSemester = 0
    @State private var gradeCounts = true
    
    @State private var isShowingNewSemester = false
    @State private var newSemester = ""
    
    @Binding var isPresented: Bool
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Semester.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Semester.title, ascending: true)]) var semesters: FetchedResults<Semester>
    
    @State private var semesterChooser = 0
    @State private var simulationChooser = 0
    
    init(subject bindedSubject: Subject?, isPresented: Binding<Bool>) {
        self._subject = State(initialValue: bindedSubject)
        self._isPresented = isPresented
        
        if let subject = bindedSubject {
            self._title = State(initialValue: subject.title ?? "")
            self._grade = State(initialValue: String(subject.grade))
            self._active = State(initialValue: subject.active)
            self._simulation = State(initialValue: subject.simulation)
            self._simMin = State(initialValue: String(subject.simMin))
            self._simMax = State(initialValue: String(subject.simMax))
            self._weight = State(initialValue: String(subject.weight))
        } else {
            self._title = State(initialValue: "")
            self._grade = State(initialValue: "1.0")
            self._active = State(initialValue:true)
            self._simulation = State(initialValue:false)
            self._simMin = State(initialValue:"1.0")
            self._simMax = State(initialValue:"4.0")
            self._weight = State(initialValue:"1.0")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                
                Section() {
                    TextField("Titel", text: self.$title)
                }
                
                Section(header: Text("Note")) {
                    Picker(selection: $simulationChooser, label: Text("Semester")) {
                        Text("Eingetragene Note").tag(0)
                        Text("Simulierte Note").tag(1)
                    }.pickerStyle(SegmentedPickerStyle())
                    if (simulationChooser == 0) {
                        HStack {
                            Text("Note:")
                            TextField("Note", text: self.$grade)

                        }
                    } else {
                        VStack(spacing: 0) {
                            HStack {
                                Text("Beste Note:")
                                TextField("Note", text: self.$simMin)
                            }
                           Divider()
                            .offset(x: 0, y: 10)
                        }
                        HStack {
                            Text("Schlechteste Note:")
                            TextField("Note", text: self.$simMax)
                        }
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
                    .disabled(!self.isSavable())
                }
                
            }
            .navigationBarTitle(Text(self.getNavigationTitle()), displayMode: .inline)
            .navigationBarItems(leading:
                Button(action: {
                    self.isPresented = false
                    self.subject = nil
                }) {
                    Text("Abbrechen")
                }
            )
        }
    }
    
    func getNavigationTitle() -> String {
        if (self.subject != nil) {
            return "Fach bearbeiten"
        } else {
            return "Neues Fach"
        }
    }
    
    func isSavable() -> Bool {
        
        if (self.title == "") {
            return false
        }
        if (self.grade == "") {
            return false
        }
        if (self.weight == "") {
            return false
        }
        
        if (self.semesterChooser == 1) {
            if (self.newSemester == "") {
                return false
            }
        }
        
        return true
    }
    
    func saveSubject() {
        var subject: Subject
        if (self.subject != nil) {
            subject = self.subject!
        } else {
            subject = Subject(context: self.managedObjectContext)
        }
        subject.title = self.title
        subject.active = true
        subject.simulation = self.simulationChooser == 1
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
