//
//  SubjectCellView.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 09.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

struct SubjectCellView: View {
    
    @State var subject: Subject
    
    @State var refreshing = false
    var didSave =  NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
    
    var body: some View {
        let average = getAverage(subject: subject)

        return
            HStack {
                Text(subject.title ?? "Unknown")
                refreshing ? Spacer() : Spacer()
                Text(average > 0.0 ? String(format: "%.2f", average) : "")
            }
            .onReceive(self.didSave) { _ in
                self.refreshing.toggle()
            }
    }
    
    func getAverage(subject: Subject) -> Float {
        var sum = Float(0)
        var count = 0
        for exam in subject.examsArray {
            sum += exam.grade
            count += 1
        }
        
        if (count > 0) {
            return sum / Float(count)
        }
        return 0.0
    }
}

