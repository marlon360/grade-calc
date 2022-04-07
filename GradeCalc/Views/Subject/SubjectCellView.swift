//
//  SemesterCellView.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 09.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

extension Float {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

struct SubjectCellView: View {
    
    @State var subject: Subject
    
    @State var refreshing = false
    var didSave =  NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
    
    var body: some View {
            HStack {
                Text(subject.title ?? "Unknown")
                if (subject.weight != 1.0) {
                    Text(subject.weight.clean + "x")
                        .bold()
                        .font(.footnote)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color(UIColor(named: "Orange") ?? .orange))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
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
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60, maxHeight: 60)
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
