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
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Semester.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Semester.title, ascending: true)]) var semesters: FetchedResults<Semester>
    
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
                        .font(.system(size: 52))
                        .bold()
                    Text("Aktueller Durchschnitt")
                        .font(.system(size: 16))
                        .padding(.top, 2)
                }
                .padding(.top, -38)
                .foregroundColor(Color.white)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 154, alignment: .trailing)
    }
    
    
    func getAverage(semester: FetchedResults<Semester>) -> Float {
        var sum = Float(0)
        var count: Float = 0.0
        for semester in semesters {
            for subject in semester.subjectsArray {
                if subject.active {
                    sum += subject.grade
                    count += subject.weight
                }
            }
        }
        if (count > 0.0) {
            return sum / count
        }
        return 0.0
    }
}
