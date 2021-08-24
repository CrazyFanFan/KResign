//
//  ProvisioningProfilePicker.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/21.
//

import SwiftUI
import UniformTypeIdentifiers

struct ProvisioningProfilePicker: View {
    var defaultProvisioningProfile: ProvisioningProfile?
    @Binding var provisioningProfile: ProvisioningProfile?
    @State private var manager = ProvisioningProfileManager.shared
    @State private var isTarget = false

    var body: some View {
        HStack {
            ZStack(alignment: .leading) {
                Picker("", selection: $provisioningProfile) {
                    ForEach(manager.provisioningProfiles, id: \.self) {
                        // 这里必须 as ProvisioningProfile? 否则和 selection Type 不匹配
                        (Text("\($0.name) (\($0.bundleIdentifierWithoutTeamID))") + append(for: $0))
                            .tag($0 as ProvisioningProfile?)
                    }
                }
                .labelsHidden()

                if provisioningProfile == nil {
                    Text("Select a provisioning profile")
                        .foregroundColor(.secondary.opacity(0.75))
                        .padding(.leading, 3)
                }
            }
            Button("⟳") {
                manager.reload()
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $isTarget) { loadPath(from: $0) }
    }

    private func append(for provisioningProfile: ProvisioningProfile?) -> Text {
        (provisioningProfile == defaultProvisioningProfile ?
            Text("  (Default)").bold().font(.footnote).foregroundColor(.green.opacity(0.75)):
            Text(""))
    }

    private func loadPath(from providers: [NSItemProvider]) -> Bool {
        guard let item = providers.first(where: { $0.canLoadObject(ofClass: URL.self) }) else { return false }

        item.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (data, error) in
            if let _ = error {
                // TODO error
                return
            }

            guard let urlData = data as? Data,
                  let urlString = String(data: urlData, encoding: .utf8),
                  let url = URL(string: urlString) else {
                // TODO error
                return
            }

            // map to fileURL
            let fileURL = URL(fileURLWithPath: url.path)

            guard manager.provisionExtensions.contains(fileURL.pathExtension),
                    let provisioningProfile = ProvisioningProfile(with: fileURL) else {
                // TODO error
                return
            }

            DispatchQueue.main.async {
                self.manager.append(provisioningProfile: provisioningProfile)
                self.provisioningProfile = provisioningProfile
            }
        }

        return true
    }
}

struct ProvisioningProfilePicker_Previews: PreviewProvider {
    static var previews: some View {
        ProvisioningProfilePicker(provisioningProfile: .constant(nil))
    }
}
