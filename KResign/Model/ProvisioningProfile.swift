//
//  ProvisioningProfile.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/20.
//

import Foundation
import MobileProvision

private var displayCache = [String: String]()

typealias ProvisioningProfile = MobileProvision
extension ProvisioningProfile {
    var pickerDisplay: String {
        if let display = displayCache[uuid] { return display }

        let display: String

        if let id = entitlements.applicationIdentifier {
            display = "\(name) (\(id))"
        } else {
            display = name
        }

        displayCache[uuid] = display

        return display
    }
}
