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
                if (subject.simulation) {
                    Text(String(format: "%.2f - %.2f", subject.simMin, subject.simMax))
                    .bold()
                } else {
                    Text(String(format: "%.2f", subject.grade))
                    .bold()
                }
            }
            .onReceive(self.didSave) { _ in
                self.refreshing.toggle()
            }
            .padding(20)
            .background(Color(UIColor(named: "WhiteBackground") ?? .white))
            .foregroundColor(.primary)
            .cornerRadius(16)
            .shadow(color: Color(.darkGray).opacity(0.6), radius: 1.4, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(subject.simulation ? Color(UIColor(named: "Purple") ?? .purple).opacity(0.6) : Color.white.opacity(0), lineWidth: 2)
            )
                .opacity(subject.active ? 1.0 : 0.3)
    }
}
