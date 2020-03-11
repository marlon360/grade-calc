//
//  SemesterCellView.swift
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
            HStack {
                Text(subject.title ?? "Unknown")
                refreshing ? Spacer() : Spacer()
                Text(String(format: "%.2f", subject.grade))
            }
            .onReceive(self.didSave) { _ in
                self.refreshing.toggle()
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color(.lightGray), radius: 1.4, x: 0, y: 1)
    }
}
