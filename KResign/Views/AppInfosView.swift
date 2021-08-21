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
//        VStack {
            ForEach(appInfos.indices, id: \.self) { index in
                AppInfoView(app: $appInfos[index])
            }
//        }
    }
}

struct AppInfosView_Previews: PreviewProvider {
    static var previews: some View {
        AppInfosView(appInfos: .constant([]))
    }
}

struct AppInfoView: View {
    @Binding var app: AppInfo

    var body: some View {
        HStack {
            Text(app.display + ":").font(.body)
            ProvisioningProfilePicker(provisioningProfile: $app.newProvisioning)
        }
    }
}

struct AppInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AppInfoView(app: .constant(.init(
                                    rootURL: URL(fileURLWithPath: ""),
                                    bundleID: "",
                                    mainBundleID: "",
                                    provisioning: .init(with: URL(fileURLWithPath: ""))!)))
    }
}
