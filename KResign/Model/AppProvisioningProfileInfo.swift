//
//  AppInfo.swift
//  KResign
//
//  Created by C凡 on 2021/8/21.
//

import Foundation
import Combine

struct AppProvisioningProfileInfo: Hashable {
    var rootURL: URL
    var name: String
    var bundleID: String
    var mainBundleID: String
    var provisioning: ProvisioningProfile

    var newProvisioning: ProvisioningProfile

    var display: String

    init(
        rootURL: URL,
        name: String,
        bundleID: String,
        mainBundleID: String,
        provisioning: ProvisioningProfile
    ) {
        self.rootURL = rootURL
        self.name = name
        self.bundleID = bundleID
        self.mainBundleID = mainBundleID
        self.provisioning = provisioning

        newProvisioning = provisioning
        display = bundleID == mainBundleID ?
            "MainApp" :
            bundleID.components(separatedBy: ".").last!
    }
}
