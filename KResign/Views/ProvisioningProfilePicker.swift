//
//  ProvisioningProfilePicker.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/21.
//

import SwiftUI

struct ProvisioningProfilePicker: View {
    @Binding var provisioningProfile: ProvisioningProfile?
    @State var appedProvisioningProfile: [ProvisioningProfile]
    @State private var provisioningProfiles: [ProvisioningProfile] = []

    private var allItems: [ProvisioningProfile] {
        provisioningProfiles +
            appedProvisioningProfile.filter { !provisioningProfiles.contains($0) }
    }

    var body: some View {
        HStack {
            ZStack(alignment: .leading) {

                Picker("", selection: $provisioningProfile) {
                    ForEach(allItems, id: \.self) {
                        // 这里必须 as ProvisioningProfile? 否则和 selection Type 不匹配
                        Text($0.name)
                            .tag($0 as ProvisioningProfile?)
                    }
                }.labelsHidden()

                if provisioningProfile == nil {
                    Text("Select a provisioninp profile")
                        .foregroundColor(.secondary.opacity(0.75))
                        .padding(.leading, 3)
                }
            }

            Button("↻") {
                provisioningProfile = nil
                loadProvisioningProfiles()
            }
        }
        .onAppear(perform: {
            loadProvisioningProfiles()
        })
    }

    private func loadProvisioningProfiles() {
        provisioningProfiles = FileHelper.share.getProvisioningProfiles()
    }
}

struct ProvisioningProfilePicker_Previews: PreviewProvider {
    static var previews: some View {
        ProvisioningProfilePicker(
            provisioningProfile: .constant(nil),
            appedProvisioningProfile: []
        )
    }
}
