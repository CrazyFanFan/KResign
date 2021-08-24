//
//  AppInfosView.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/22.
//

import SwiftUI

struct AppInfosView: View {
    @Binding var appInfos: [AppInfo]

    var body: some View {
        if !appInfos.isEmpty {
            ScrollView {
                ForEach(appInfos.indices, id: \.self) { index in
                    AppInfoView(app: $appInfos[index])
                }
            }.frame(minHeight: 200)
        }
    }
}

struct AppInfosView_Previews: PreviewProvider {
    static var previews: some View {
        AppInfosView(appInfos: .constant([]))
    }
}

struct AppInfoView: View {
    @Binding var app: AppInfo
    @State private var isNameShow: Bool = false

    var body: some View {
        HStack(alignment: .top) {
            HStack {
                Text(app.display + ":").font(.body)
                    .popover(isPresented: $isNameShow) {
                        Text("Name: \(app.name)\nBundleID: \(app.bundleID)")
                            .padding()
                    }
                    .onHover {
                        isNameShow = $0
                    }
                Spacer()
            }.frame(width: 100)

            ProvisioningProfilePicker(
                defaultProvisioningProfile: app.provisioning,
                provisioningProfile: $app.newProvisioning
            )
        }
    }
}

struct AppInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AppInfoView(app: .constant(.init(
            rootURL: URL(fileURLWithPath: ""),
            name: "name",
            bundleID: "",
            mainBundleID: "",
            provisioning: .init(with: URL(fileURLWithPath: ""))!)))
    }
}
