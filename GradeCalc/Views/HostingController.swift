//
//  HostingController.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 11.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

class HostingController: UIHostingController<AnyView> {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
