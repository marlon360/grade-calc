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
                ExamCellView(exam: exam)
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
            .navigationBarTitle(subject.title ?? "Prüfungen")
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

