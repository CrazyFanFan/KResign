//
//  ProvisioningProfileManager.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/21.
//

import Foundation
import Combine

class ProvisioningProfileManager: ObservableObject {
    static let shared: ProvisioningProfileManager = .init()

    private var provisioningProfiles: [ProvisioningProfile] = FileHelper.share.getProvisioningProfiles()
    private var appendProvisioningProfile: [ProvisioningProfile] = []

    @Published var allProvisioningProfiles: [ProvisioningProfile] = []

    private init() {
        reload()
    }

    func append(provisioningProfile: ProvisioningProfile) {
        appendProvisioningProfile.append(provisioningProfile)
        reload(isTriggeredByAppend: true)
    }

    func append(provisioningProfiles: [ProvisioningProfile]) {
        appendProvisioningProfile.append(contentsOf: provisioningProfiles)
        reload(isTriggeredByAppend: true)
    }

    func reload(isTriggeredByAppend: Bool = false) {
        if !isTriggeredByAppend {
            provisioningProfiles = FileHelper.share.getProvisioningProfiles()
        }

        self.allProvisioningProfiles = self.provisioningProfiles +
            self.appendProvisioningProfile.filter { !self.provisioningProfiles.contains($0) }
    }
}
