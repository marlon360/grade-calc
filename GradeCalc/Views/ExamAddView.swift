//
//  ExamAddView.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 08.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

struct ExamAddiew: View {
    
    @State private var newClassTitle = ""
    @State private var newClassWeight = "1"
    @State private var newGrade = "1"
    
    @Binding var isPresented: Bool
    
    @State public var subject: Subject
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    
    var body: some View {
        
        NavigationView {
            Form {
                Section() {
                    TextField("Name", text: self.$newClassTitle)
                }
                
                Section(header: Text("Gewichtung")) {
                    TextField("Gewichtung", text: self.$newClassWeight)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Note")) {
                    TextField("Note", text: self.$newGrade)
                        .keyboardType(.decimalPad)
                }
                
                Section() {
                    Button(action: {
                        if (self.newClassTitle != "") {
                            let exam = Exam(context: self.managedObjectContext)
                            exam.title = self.newClassTitle
                            exam.grade = Float(self.newGrade)!
                            exam.createdAt = Date()
                            exam.weight = Float(self.newClassWeight)!
                            self.subject.addToExams(exam)
                            
                            do {
                                try self.managedObjectContext.save()
                            } catch {
                                print(error)
                            }
                            self.newClassTitle = ""
                        }
                        self.isPresented = false
                    }) {
                        Text("Hinzufügen")
                    }
                }
                
            }
            .navigationBarTitle(Text("Neue Prüfung"), displayMode: .inline)
            .navigationBarItems(leading:
                Button(action: {
                    self.isPresented = false
                }) {
                    Text("Abbrechen")
                }
            )
        }
    }
}
