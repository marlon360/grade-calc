//
//  SemesterCellView.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 09.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

struct SemesterCellView: View {
    
    @State var semester: Semester
    
    @State var refreshing = false
    var didSave =  NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
    
    var body: some View {
        let average = getAverage(semester: semester)
        
        return
            HStack {
                Text(semester.title ?? "Unknown")
                refreshing ? Spacer() : Spacer()
                Text(average > 0.0 ? String(format: "%.2f", average) : "")
            }
            .onReceive(self.didSave) { _ in
                self.refreshing.toggle()
            }
    }
    
    func getAverage(semester: Semester) -> Float {
        var sum = Float(0)
        var count = 0
        for subject in semester.subjectsArray {
            for exam in subject.examsArray {
                sum += exam.grade
                count += 1
            }
        }
        if (count > 0) {
            return sum / Float(count)
        }
        return 0.0
    }
}
