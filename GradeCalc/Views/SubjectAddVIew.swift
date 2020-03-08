//
//  SubjectAddVIew.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 08.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

struct SubjectAddiew: View {
    
    @State private var newClassTitle = ""
    @State private var newClassWeight = "1"
    
    @Binding var isPresented: Bool
    
    @State public var semester: Semester
    
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
                
                Section() {
                    Button(action: {
                        if (self.newClassTitle != "") {
                            let subject = Subject(context: self.managedObjectContext)
                            subject.title = self.newClassTitle
                            subject.semester = self.semester
                            subject.weight = Float(self.newClassWeight)!
                            self.semester.addToSubjects(subject)
                            
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
            .navigationBarTitle(Text("Neues Fach"), displayMode: .inline)
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
