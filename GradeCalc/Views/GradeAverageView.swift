//
//  GradeAverageView.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 09.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

struct GradeAverageView: View {
    
    @State var semesters: FetchedResults<Semester>
    
    var body: some View {
        let average = getAverage(semester: semesters)

        return Text(average > 0.0 ? String(format: "Durchschnitt: %.2f", average) : "Noch keine Noten eingetragen")
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
