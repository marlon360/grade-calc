//
//  SemesterAddVIew.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 08.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

struct SemesterAddiew: View {
    
    @State private var newSemesterTitle = ""
    
    @Binding var isPresented: Bool
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        
        NavigationView {
            Form {
                Section() {
                    TextField("Name", text: self.$newSemesterTitle)
                }
                
                Section() {
                    Button(action: {
                        if (self.newSemesterTitle != "") {
                            let semester = Semester(context: self.managedObjectContext)
                            semester.title = self.newSemesterTitle
                            
                            do {
                                try self.managedObjectContext.save()
                            } catch {
                                print(error)
                            }
                            self.newSemesterTitle = ""
                        }
                        self.isPresented = false
                    }) {
                        Text("Hinzufügen")
                    }
                }
                
            }
            .navigationBarTitle(Text("Neues Semester"), displayMode: .inline)
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
