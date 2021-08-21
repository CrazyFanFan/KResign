//
//  AppInfo.swift
//  KResign
//
//  Created by C凡 on 2021/8/21.
//

import Foundation
import Combine

struct AppInfo: Hashable {
    var rootURL: URL
    var bundleID: String
    var mainBundleID: String
    var provisioning: ProvisioningProfile

    var newProvisioning: ProvisioningProfile?

    var display: String

    init(
        rootURL: URL,
        bundleID: String,
        mainBundleID: String,
        provisioning: ProvisioningProfile
    ) {
        self.rootURL = rootURL
        self.bundleID = bundleID
        self.mainBundleID = mainBundleID
        self.provisioning = provisioning

        newProvisioning = provisioning
        display = bundleID == mainBundleID ?
            "MainApp" :
            bundleID.components(separatedBy: ".").last!
    }
}
