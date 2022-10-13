//
//  ProvisioningProfile.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/20.
//

import Foundation
import MobileProvision

struct ProvisioningProfile: Hashable {
    var raw: MobileProvision
    var pickerDisplay: String
    var certificates: [String]

    var path: URL { raw.path }

    public init?(with fileURL: URL) {
        guard let raw = MobileProvision(with: fileURL) else { return nil }

        self.raw = raw

        if let id: String = raw.applicationIdentifier {
            pickerDisplay = "\(raw.name) (\(id))"
        } else {
            pickerDisplay = raw.name
        }

        certificates = raw.developerCertificates.map { $0.sha1 }
    }
}
