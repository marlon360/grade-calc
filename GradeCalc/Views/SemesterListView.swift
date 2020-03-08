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
    
    @State private var refreshing = false
    private var didSave =  NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
    
    var body: some View {
        let average = getAverage(semester: semesters)
        return NavigationView {
            VStack {
                List {
                    ForEach(self.semesters) { semester in
                        NavigationLink(destination: SubjectListView(semester: semester)) {
                            Text(semester.title ?? "Unknown")
                        }
                        .onReceive(self.didSave) { _ in
                            self.refreshing.toggle()
                        }
                    }
                    .onDelete(perform: removeSemester)
                }
                Text(self.refreshing ? "" : "")
                Text(average > 0.0 ? String(format: "Durchschnitt: %.2f", average) : "Noch keine Noten eingetragen")
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
    
    func getAverage(semester: FetchedResults<Semester>) -> Float {
        var sum = Float(0)
        var count = 0
        for semester in semesters {
            for subject in semester.subjectsArray {
                for exam in subject.examsArray {
                    sum += exam.grade
                    count += 1
                }
            }
        }
        if (count > 0) {
            return sum / Float(count)
        }
        return 0.0
    }
}
