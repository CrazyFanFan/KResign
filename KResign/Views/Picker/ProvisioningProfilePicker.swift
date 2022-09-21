//
//  ProvisioningProfilePicker.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/21.
//

import SwiftUI
import UniformTypeIdentifiers

extension Text {
    func `default`() -> Text {
        Text("DefaultIcon").foregroundColor(.blue) + self
    }

    func current() -> Text {
        Text("DefaultIcon").foregroundColor(.green) + self
    }
}

struct ProvisioningProfilePicker: View {
    var `default`: ProvisioningProfile
    @Binding var selection: ProvisioningProfile
    @StateObject private var manager = ProvisioningProfileManager.shared
    @State private var isTarget = false

    var body: some View {
        Picker("", selection: $selection) {
            ForEach(manager.provisioningProfiles, id: \.self) { profile in
                display(for: profile).tag(profile)
            }
        }
        .labelsHidden()
        .onDrop(of: [.fileURL], isTargeted: $isTarget) { loadPath(from: $0) }
    }

    private func display(for profile: ProvisioningProfile) -> Text {
        switch (profile, profile) {
        case (self.default, self.selection):
            return Text(profile.pickerDisplay).current().default()
        case (self.default, _):
            return Text(profile.pickerDisplay).default()
        case (self.selection, _):
            return Text(profile.pickerDisplay).current()
        default:
            return Text(profile.pickerDisplay)
        }
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
                self.selection = provisioningProfile
            }
        }

        return true
    }
}

// struct ProvisioningProfilePicker_Previews: PreviewProvider {
//    static var previews: some View {
//        ProvisioningProfilePicker(default: <#T##ProvisioningProfile#>, selection: <#T##Binding<ProvisioningProfile>#>)
//    }
// }
