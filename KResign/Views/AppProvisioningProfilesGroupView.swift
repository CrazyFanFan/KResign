//
//  AppInfosView.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/22.
//

import SwiftUI

struct AppProvisioningProfilesGroupView: View {
    @Binding var appInfos: [AppProvisioningProfileInfo]
    private var manager: ProvisioningProfileManager = .shared

    init(appInfos: Binding<[AppProvisioningProfileInfo]>) {
        self._appInfos = appInfos
    }

    var body: some View {
        if !appInfos.isEmpty {
            List {
                Section {
                    ForEach(appInfos.indices, id: \.self) { index in
                        AppProvisioningProfileView(index: index, app: $appInfos[index])
                    }
                } header: {
                    HStack {
                        Text("Default")
                        Text.default()
                        Divider()

                        Text("Current")
                        Text.current()
                        Divider()

                        Text("Total: \(appInfos.count)")
                        Spacer()
                        Button {
                            manager.reload()
                        } label: {
                            Image("arrow.clockwise")
                        }
                    }
                }
            }
            .frame(minHeight: 150)
        }
    }
}

struct AppProvisioningProfilesInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AppProvisioningProfilesGroupView(appInfos: .constant([]))
    }
}

struct AppProvisioningProfileView: View {
    var index: Int?
    @Binding var app: AppProvisioningProfileInfo
    @State private var isNameShow: Bool = false

    var body: some View {
        HStack(alignment: .top) {
            HStack {
                if let index = index {
                    Text("\(index + 1) ")
                }
                Text(app.display).font(.body)
                    .lineLimit(1)
                    .popover(isPresented: $isNameShow) {
                        Text(app.name)
                            .padding()
                    }
                    .onHover {
                        isNameShow = $0
                    }
                Spacer()
            }
            .frame(width: 150)

            ProvisioningProfilePicker(
                default: app.provisioning,
                selection: $app.newProvisioning
            )
        }
    }
}
//
// struct AppProvisioningProfileInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppProvisioningProfileView(app: .constant(.init(
//            rootURL: URL(fileURLWithPath: ""),
//            name: "name",
//            bundleID: "",
//            mainBundleID: "",
//            provisioning: .init(with: URL(fileURLWithPath: ""))!)))
//    }
// }
