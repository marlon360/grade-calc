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
    
    @Binding var menuOpen: Bool
    @Binding var simulation: Bool
    
    var body: some View {
        let average = getAverage(semester: semesters)
        let simAverage = getSimulatedAverage(semester: semesters)
        
        let averageString: LocalizedStringKey = "current average"
        let simAverageString: LocalizedStringKey = "simulated average"

        return
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .background(LinearGradient(gradient: Gradient(colors: [Color(UIColor(named: "GradientColor1") ?? .blue), Color(UIColor(named: "GradientColor2") ?? .purple)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .edgesIgnoringSafeArea(.all)
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    self.menuOpen.toggle()
                                }
                            }) {
                                Image(systemName: "ellipsis")
                                .font(.system(size: 32, weight: .bold))
                            }
                            .foregroundColor(.white)
                        }
                        .padding(30)
                        Spacer()
                    }
                    .padding(.top, -15)
                VStack {
                    if(simulation) {
                        Text(simAverage.0 > 0.0 ? String(format: "%.2f - %.2f", simAverage.0, simAverage.1) : "0")
                        .font(.system(size: 42))
                        .bold()
                    } else {
                    Text(average > 0.0 ? String(format: "%.2f", average) : "0")
                        .font(.system(size: 52))
                        .bold()
                    }
                    Text(!simulation ? averageString :simAverageString)
                        .font(.system(size: 16))
                        .padding(.top, 2)
                    
                }
                .padding(.top, -38)
                .foregroundColor(Color.white)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 154, alignment: .trailing)
    }
    
    
    func getAverage(semester: FetchedResults<Semester>) -> Float {
        var sum = Float(0)
        var count: Float = 0.0
        for semester in semesters {
            for subject in semester.subjectsArray {
                if subject.active && !subject.simulation {
                    sum += subject.grade * subject.weight
                    count += subject.weight
                }
            }
        }
        if (count > 0.0) {
            return sum / count
        }
        return 0.0
    }
    
    func getSimulatedAverage(semester: FetchedResults<Semester>) -> (Float, Float) {
        var sumMin = Float(0)
        var sumMax = Float(0)
        var count: Float = 0.0
        for semester in semesters {
            for subject in semester.subjectsArray {
                if subject.active {
                    if (subject.simulation) {
                        sumMin += subject.simMin * subject.weight
                        sumMax += subject.simMax * subject.weight
                    } else {
                        sumMin += subject.grade * subject.weight
                        sumMax += subject.grade * subject.weight
                    }
                    count += subject.weight
                }
            }
        }
        if (count > 0.0) {
            return (sumMin / count, sumMax / count)
        }
        return (0.0, 0.0)
    }
}
