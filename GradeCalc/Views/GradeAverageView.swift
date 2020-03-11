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

        return
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .background(LinearGradient(gradient: Gradient(colors: [.init(red: 0.03, green: 0.62, blue: 0.96), .init(red: 0.69, green: 0.22, blue: 1.0)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Text(average > 0.0 ? String(format: "%.2f", average) : "0")
                        .font(.system(size: 48))
                        .bold()
                    Text("Aktueller Durchschnitt")
                        .font(.system(size: 16))
                        .padding(.top, 5)
                }
                .padding(.top, -10)
                .foregroundColor(Color.white)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 130, alignment: .trailing)
    }
    
    
    func getAverage(semester: FetchedResults<Semester>) -> Float {
        var sum = Float(0)
        var count = 0
        for semester in semesters {
            for subject in semester.subjectsArray {
                sum += subject.grade
                count += 1
            }
        }
        if (count > 0) {
            return sum / Float(count)
        }
        return 0.0
    }
}
