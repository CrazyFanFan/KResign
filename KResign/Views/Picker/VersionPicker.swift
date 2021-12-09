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
        HStack {
            Text("Version")
            TextField("CFBundleShortVersionString", text: $version)
                .modifier(WarningModifier(status: $status, shouldWaring: version.isEmpty))

            Text("Build Version")
            TextField("CFBundleVersion", text: $buildVersion)
                .modifier(WarningModifier(status: $status, shouldWaring: buildVersion.isEmpty))
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

/*
 //
 //  VersionPicker.swift
 //  VersionPicker
 //
 //  Created by Crazy凡 on 2021/8/26.
 //

 import SwiftUI

 struct VersionPicker: View {
     @Binding var version: String {
         didSet {
             innerVersion = version
         }
     }
     @Binding var buildVersion: String {
         didSet {
             innerBuildVersion = buildVersion
         }
 }
     @State private var innerVersion: String
     @State private var innerBuildVersion: String
     @Binding var status: InfoViewStatus

     init(version: Binding<String>, buildVersion: Binding<String>, status: Binding<InfoViewStatus>) {
         self._version = version
         self.innerVersion = version.wrappedValue
         self._buildVersion = buildVersion
         self.innerBuildVersion = buildVersion.wrappedValue
         self._status = status
     }

     var body: some View {
         HStack {
             Text("Version")
             TextField("CFBundleShortVersionString", text: $innerVersion, onCommit: {
                 version = innerVersion
             })
                 .modifier(WarningModifier(status: $status, shouldWaring: version.isEmpty))

             Text("Build Version")
             TextField("CFBundleVersion", text: $innerBuildVersion, onCommit: {
                 buildVersion = innerBuildVersion
             })
                 .modifier(WarningModifier(status: $status, shouldWaring: buildVersion.isEmpty))
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

 */
