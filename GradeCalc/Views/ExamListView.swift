//
//  ExamListView.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 08.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

struct ExamListView: View {
    
    @State var subject: Subject
    
    @State private var refreshing = false
        
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var addSheetVisible = false
    
    var body: some View {
        List {
            ForEach(subject.examsArray, id: \.self) { exam in
                Text(exam.title ?? "Unknown")
            }
            .onDelete(perform: removeClass)
            Text(self.refreshing ? "" : "")
        }
        
        .navigationBarItems(trailing:
            Button(action: {
                self.addSheetVisible = true
            }) {
                Image(systemName: "plus")
            }
        )
        .navigationBarTitle("Prüfungen")
        .sheet(isPresented: $addSheetVisible) {
            ExamAddiew(isPresented: self.$addSheetVisible, subject: self.subject)
                .environment(\.managedObjectContext, self.managedObjectContext)
        }
    }
    
   func removeClass(at offsets: IndexSet) {
        for index in offsets {
            let exam = subject.examsArray[index]
            subject.removeFromExams(exam)
            managedObjectContext.delete(exam)
        }
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
        self.refreshing.toggle()
    }
}

