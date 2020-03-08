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
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.semesters) { semester in
                    NavigationLink(destination: SubjectListView(semester: semester)) {
                        Text(semester.title ?? "Unknown")
                    }
                        
                }
                .onDelete(perform: removeSemester)
            }
            
            .navigationBarItems(leading: EditButton(), trailing:
                Button(action: {
                    self.addSheetVisible = true
                }) {
                    Image(systemName: "plus")
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
            managedObjectContext.delete(semester)
        }
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
    }
}
