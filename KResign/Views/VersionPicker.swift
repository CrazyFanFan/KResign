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

    var body: some View {
        HStack {
            Text("Version")
            TextField("CFBundleShortVersionString", text: $version)
            Text("Build Version")
            TextField("CFBundleVersion", text: $buildVersion)
        }
    }
}

struct VersionPicker_Previews: PreviewProvider {
    static var previews: some View {
        VersionPicker(version: .constant("5.6.7"), buildVersion: .constant("123456"))
    }
}
