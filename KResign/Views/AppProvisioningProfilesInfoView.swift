//
//  AppInfosView.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/22.
//

import SwiftUI

struct AppProvisioningProfilesInfoView: View {
    @Binding var appInfos: [AppProvisioningProfileInfo]

    var body: some View {
        if !appInfos.isEmpty {
            List {
                ForEach(appInfos.indices, id: \.self) { index in
                    AppProvisioningProfileInfoView(app: $appInfos[index])
                }
            }
            .frame(minHeight: 150, maxHeight: 450)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
            )
        }
    }
}

struct AppProvisioningProfilesInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AppProvisioningProfilesInfoView(appInfos: .constant([]))
    }
}

struct AppProvisioningProfileInfoView: View {
    @Binding var app: AppProvisioningProfileInfo
    @State private var isNameShow: Bool = false

    var body: some View {
        HStack(alignment: .top) {
            HStack {
                Text(app.display + ":").font(.body)
                    .lineLimit(1)
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

struct AppProvisioningProfileInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AppProvisioningProfileInfoView(app: .constant(.init(
            rootURL: URL(fileURLWithPath: ""),
            name: "name",
            bundleID: "",
            mainBundleID: "",
            provisioning: .init(with: URL(fileURLWithPath: ""))!)))
    }
}
