//
//  ProvisioningProfilePicker.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/21.
//

import SwiftUI

struct ProvisioningProfilePicker: View {
    @Binding var provisioningProfile: ProvisioningProfile?
    @State private var provisioningProfileManager = ProvisioningProfileManager.shared

    var body: some View {
        HStack {
            ZStack(alignment: .leading) {

                Picker("", selection: $provisioningProfile) {
                    ForEach(provisioningProfileManager.allProvisioningProfiles, id: \.self) {
                        // 这里必须 as ProvisioningProfile? 否则和 selection Type 不匹配
                        Text("\($0.name) (\($0.bundleIdentifierWithoutTeamID))")
                            .tag($0 as ProvisioningProfile?)
                    }
                }.labelsHidden()

                if provisioningProfile == nil {
                    Text("Select a provisioning profile")
                        .foregroundColor(.secondary.opacity(0.75))
                        .padding(.leading, 3)
                }
            }

            Button("↻") {
                provisioningProfile = nil
                provisioningProfileManager.reload()
            }
        }
    }
}

struct ProvisioningProfilePicker_Previews: PreviewProvider {
    static var previews: some View {
        ProvisioningProfilePicker(provisioningProfile: .constant(nil))
    }
}
