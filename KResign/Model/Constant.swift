//
//  Constant.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/20.
//

import Foundation

enum BundleKey {
    static var kKeyBundleIDChange: String { "keyBundleIDChange" }
    static var kCFBundleIdentifier: String { "CFBundleIdentifier" }
    static var kCFBundleDisplayName: String { "CFBundleDisplayName" }
    static var kCFBundleName: String { "CFBundleName" }
    static var kCFBundleShortVersionString: String { "CFBundleShortVersionString" }
    static var kCFBundleVersion: String { "CFBundleVersion" }
    static var kCFBundleIcons: String { "CFBundleIcons" }
    static var kCFBundlePrimaryIcon: String { "CFBundlePrimaryIcon" }
    static var kCFBundleIconFiles: String { "CFBundleIconFiles" }
    static var kCFBundleIconsipad: String { "CFBundleIcons~ipad" }
    static var kMinimumOSVersion: String { "MinimumOSVersion" }
    static var kPayloadDirName: String { "Payload" }
    static var kInfoPlistFilename: String { "Info.plist" }
    static var kEntitlementsPlistFilename: String { "Entitlements.plist" }
    static var kCodeSignatureDirectory: String { "_CodeSignature" }
    static var kEmbeddedProvisioningFilename: String { "embedded" }
    static var kAppIdentifier: String { "application-identifier" }
    static var kTeamIdentifier: String { "com.apple.developer.team-identifier" }
    static var kKeychainAccessGroups: String { "keychain-access-groups" }
    static var kIconNormal: String { "iconNormal" }
    static var kIconRetina: String { "iconRetina" }
    static var kPlugIns: String { "PlugIns" }
}
