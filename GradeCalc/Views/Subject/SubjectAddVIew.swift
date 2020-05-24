//
//  SemesterAddVIew.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 08.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

final class KeyboardResponder: ObservableObject {
    private var notificationCenter: NotificationCenter
    @Published private(set) var currentHeight: CGFloat = 0

    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        currentHeight = 0
    }
}

struct SubjectAddView: View {
    
    @State var subject: Subject?
    
    @State var title: String
    @State private var grade: String
    @State private var active: Bool
    @State private var simulation: Bool
    @State private var simMin: String
    @State private var simMax: String
    @State private var weight: String
    
    @State private var selectedSemester: Int
    @State private var gradeCounts: Bool
    
    @State private var isShowingNewSemester = false
    @State private var newSemester = ""
    
    @Binding var isPresented: Bool
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Semester.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Semester.title, ascending: true)]) var semesters: FetchedResults<Semester>
    
    @State private var semesterChooser = 0
    @State private var simulationChooser: Int
    
    @ObservedObject private var keyboard = KeyboardResponder()
    
    init(subject bindedSubject: Subject?, isPresented: Binding<Bool>) {
        self._subject = State(initialValue: bindedSubject)
        self._isPresented = isPresented
        
        if let subject = bindedSubject {
            self._title = State(initialValue: subject.title ?? "")
            self._grade = State(initialValue: String(subject.grade))
            self._active = State(initialValue: subject.active)
            self._simulation = State(initialValue: subject.simulation)
            self._simulationChooser = State(initialValue: subject.simulation ? 1 : 0)
            self._simMin = State(initialValue: String(subject.simMin))
            self._simMax = State(initialValue: String(subject.simMax))
            self._weight = State(initialValue: String(subject.weight))
            self._selectedSemester = State(initialValue: 0)
            self._gradeCounts = State(initialValue: subject.weight != 0.0)
        } else {
            self._title = State(initialValue: "")
            self._grade = State(initialValue: "1.0")
            self._active = State(initialValue:true)
            self._simulation = State(initialValue:false)
            self._simulationChooser = State(initialValue: 0)
            self._simMin = State(initialValue:"1.0")
            self._simMax = State(initialValue:"4.0")
            self._weight = State(initialValue:"1.0")
            self._selectedSemester = State(initialValue: 0)
            self._gradeCounts = State(initialValue: true)
        }
    }
    
    var body: some View {
        
        let selectedSemesterPicker = Binding<Int>(get: {
            return self.selectedSemester
        }, set: {
            self.selectedSemester = $0
            if let subject = self.subject {
                subject.semester = self.semesters[self.selectedSemester]
            }
        })
        
        return NavigationView {
            Form {
                
                Section() {
                    TextField("title", text: self.$title)
                }
                
                Section(header: Text("grade")) {
                    Picker(selection: $simulationChooser, label: Text("semester")) {
                        Text("final grade").tag(0)
                        Text("simulated grade").tag(1)
                    }.pickerStyle(SegmentedPickerStyle())
                    if (simulationChooser == 0) {
                        HStack {
                            Text("grade:")
                            TextField("grade", text: self.$grade)
                                .keyboardType(.decimalPad)

                        }
                    } else {
                        VStack(spacing: 0) {
                            HStack {
                                Text("best grade:")
                                TextField("grade", text: self.$simMin)
                                    .keyboardType(.decimalPad)
                            }
                           Divider()
                            .offset(x: 0, y: 10)
                        }
                        HStack {
                            Text("worst grade:")
                            TextField("grade", text: self.$simMax)
                                .keyboardType(.decimalPad)
                        }
                    }
                
                }
                
                Section(header: Text("weight")) {
                    VStack(spacing: 0) {
                        Toggle(isOn: self.$gradeCounts) {
                            Text("grade counts")
                        }
                       Divider()
                        .offset(x: 0, y: 10)
                        
                    }
                    HStack {
                        Text("weight:")
                        if (self.gradeCounts) {
                            TextField("weight", text: self.$weight)
                                .keyboardType(.decimalPad)
                        } else {
                            Text("0")
                        }
                    }
                    .disabled(!self.gradeCounts)
                    .foregroundColor(self.gradeCounts ? .primary : Color.gray)
                }
                                
                Section(header: Text("semester")) {
                    Picker(selection: $semesterChooser, label: Text("semester")) {
                        Text("choose semester").tag(0)
                        Text("create semester").tag(1)
                    }.pickerStyle(SegmentedPickerStyle())
                        .onAppear {
                            if (self.semesters.count == 0) {
                                self.semesterChooser = 1
                            }
                        }
                    
                    // choose semester is selected in segemebted control
                    if (semesterChooser == 0) {
                        if (semesters.count > 0) {
                            Picker(selection: selectedSemesterPicker, label: Text("semester")) {
                                ForEach(0 ..< semesters.count) {
                                    Text(self.semesters[$0].title ?? "semester").tag($0)
                                }
                            }
                            .onAppear() {
                                if let subject = self.subject {
                                    self.selectedSemester = self.semesters.lastIndex(of: subject.semester!) ?? self.selectedSemester
                                }
                            }
                        } else {
                            Text("no semester")
                        }
                    }
                    
                    // create semester is selected in segmented control
                    if (semesterChooser == 1) {
                        TextField("semester", text: self.$newSemester)
                    }
                    
                }
                
                Section() {
                    Button(action: {
                        self.saveSubject()
                        self.isPresented = false
                    }) {
                        Text("save")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(!self.isSavable())
                }
                
            }
            .navigationBarTitle(Text(self.getNavigationTitle()), displayMode: .inline)
            .navigationBarItems(leading:
                Button(action: {
                    self.isPresented = false
                }) {
                    Text("cancel")
                }, trailing:
                Button(action: {
                    self.saveSubject()
                    self.isPresented = false
                }) {
                    Text("save")
                }.disabled(!self.isSavable())
            )
            .padding(.bottom, keyboard.currentHeight)
            .edgesIgnoringSafeArea(.bottom)
            .animation(.easeOut(duration: 0.16))
        }
    }
    
    func getNavigationTitle() -> LocalizedStringKey {
        if (self.subject != nil) {
            return "edit subject"
        } else {
            return "new subject"
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
            print(subject)
        } else {
            print("new subject")
            subject = Subject(context: self.managedObjectContext)
        }
        subject.title = self.title
        subject.active = true
        subject.simulation = self.simulationChooser == 1

        subject.simMin = self.simMin.floatValue ?? 1
        subject.simMax = self.simMax.floatValue ?? 4
        
        if (self.gradeCounts) {
            subject.weight = self.weight.floatValue ?? 1
        } else {
             subject.weight = Float(0)
        }
        subject.grade = self.grade.floatValue ?? 1

        var semester: Semester
        if (self.semesterChooser == 0) {
            semester = self.semesters[self.selectedSemester]
        } else {
            semester = Semester(context: self.managedObjectContext)
            semester.title = self.newSemester
        }
        
        subject.semester = semester
        semester.addToSubjects(subject)
        
        for semester in self.semesters {
            if semester.subjectsArray.count < 1 {
                managedObjectContext.delete(semester)
            }
        }
        
        do {
            print(subject.grade)
            try self.managedObjectContext.save()
        } catch {
            print(error)
        }
        
    }
    
}

extension String {
    var floatValue: Float? {
        if (self.contains(",")) {
            return NumberFormatter().number(from: self)?.floatValue
        } else {
            return Float(self)
        }
    }
}
