//
//  HideRowSeparatorModifier.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 07.04.22.
//  Copyright © 2022 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

struct HideRowSeparatorModifier: ViewModifier {

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content.listRowSeparator(.hidden)
        } else {
            content
        }
    }
}

extension View {
    func hideRowSeparator() -> some View {
        modifier(HideRowSeparatorModifier())
    }
}
