//
//  SubjectListView.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 08.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

struct SubjectListView: View {
    
    @State var semester: Semester
    
    @State private var refreshing = false
        
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var addSheetVisible = false
    
    var body: some View {
        List {
            ForEach(semester.subjectsArray, id: \.self) { subject in
                NavigationLink(destination: ExamListView(subject: subject)) {
                    SubjectCellView(subject: subject)
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color(.lightGray), radius: 1.4, x: 0, y: 1)
                .listRowBackground(Color(red: 0.92, green: 0.94, blue: 0.97))
            }
            .onDelete(perform: removeClass)
        }
        
        .navigationBarItems(trailing:
            Button(action: {
                self.addSheetVisible = true
            }) {
                Image(systemName: self.refreshing ? "plus" : "plus")
                .imageScale(.large)
            }
        )
        .navigationBarTitle(semester.title ?? "Fächer")
        .sheet(isPresented: $addSheetVisible) {
            SubjectAddiew(isPresented: self.$addSheetVisible, semester: self.semester)
                .environment(\.managedObjectContext, self.managedObjectContext)
        }
    }
    
   func removeClass(at offsets: IndexSet) {
        for index in offsets {
            let subject = semester.subjectsArray[index]
            semester.removeFromSubjects(subject)
            managedObjectContext.delete(subject)
        }
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
        self.refreshing.toggle()
    }
}


