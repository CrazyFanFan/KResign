//
//  VersionPicker.swift
//  VersionPicker
//
//  Created by Crazy凡 on 2021/8/26.
//

import SwiftUI

struct VersionPicker: View {
    @Binding var version: String
    @Binding var buildVersion: String
    @Binding var status: InfoViewStatus

    var body: some View {
        VStack {
            HStack {
                Text("Version")
                TextField("CFBundleShortVersionString", text: $version)
                    .modifier(WarningModifier($status, condition: version.isEmpty))
            }

            HStack {
                Text("Build")
                TextField("CFBundleVersion", text: $buildVersion)
                    .modifier(WarningModifier($status, condition: buildVersion.isEmpty))
            }
        }
    }
}

struct VersionPicker_Previews: PreviewProvider {
    static var previews: some View {
        VersionPicker(
            version: .constant("5.6.7"),
            buildVersion: .constant("123456"),
            status: .constant(.display)
        )
    }
}
