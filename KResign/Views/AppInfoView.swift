//
//  AppInfoView.swift
//  KResign
//
//  Created by C凡 on 2021/8/21.
//

import SwiftUI

struct AppInfoView: View {
    @State var appedProvisioningProfile: [ProvisioningProfile]
    @Binding var app: AppInfo

    var body: some View {
        HStack {
            Text(app.display + ":")
                .font(.body)
            ProvisioningProfilePicker(
                provisioningProfile: $app.newProvisioning,
                appedProvisioningProfile: appedProvisioningProfile
            )
        }
    }
}

//struct AppInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppInfoView(app: .ini )
//    }
//}
