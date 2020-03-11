//
//  TextFieldAlert.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 10.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//

import Foundation
import SwiftUI

struct MyAlert: View {
    @State private var text: String = ""

    var body: some View {

        VStack {
            Text("Enter Input").font(.headline).padding()

            TextField("Type text here", text: $text)
                .padding()
            Divider()
            HStack {
                Spacer()
                Button(action: {
                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: {})
                }) {

                    Text("Done")
                }
                Spacer()

                Divider()

                Spacer()
                Button(action: {
                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: {})
                }) {
                    Text("Cancel")
                }
                Spacer()
            }.padding(0)


            }.background(Color(white: 0.9))
    }
}
