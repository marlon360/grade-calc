//
//  ExamCellView.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 09.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

struct ExamCellView: View {
    
    @State var exam: Exam
    
    var body: some View {
        HStack {
            Text(exam.title ?? "Unknown")
            Spacer()
            Text(String(format: "%.2f", exam.grade))
        }
    }
}
