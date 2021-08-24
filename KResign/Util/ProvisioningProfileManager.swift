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

    @inline(__always)
    private var manager: FileManager { .default }
    let provisionExtensions: [String] = ["mobileprovision", "provisionprofile"]
    private let path = "\(NSHomeDirectory().components(separatedBy: "/Library")[0])/Library/MobileDevice/Provisioning Profiles"

    private var localProvisioningProfiles: [ProvisioningProfile] = []
    private var appendProvisioningProfile: [ProvisioningProfile] = []

    @Published var provisioningProfiles: [ProvisioningProfile] = []

    private init() {
        reload() // call reload to load init data.
    }

    func reload(isTriggeredByAppend: Bool = false) {
        if !isTriggeredByAppend {
            localProvisioningProfiles = loadLocalProvisioningProfiles()
        }

        self.provisioningProfiles = self.localProvisioningProfiles +
            self.appendProvisioningProfile.filter { !self.localProvisioningProfiles.contains($0) }
    }

    private func loadLocalProvisioningProfiles() -> [ProvisioningProfile] {
        autoreleasepool {
            do {
                return try manager.contentsOfDirectory(atPath: path)
                    .map { "\(path)/\($0)" }
                    .filter { manager.fileExists(atPath: $0) } // 确认文件存在
                    .map { URL(fileURLWithPath: $0) } // 转成URL
                    .filter { provisionExtensions.contains($0.pathExtension.lowercased()) } // 确认文件扩展名
                    .compactMap { ProvisioningProfile(with: $0) } // 转换成功
            } catch {
                // TODO log error
                return []
            }
        }
    }

    func append(provisioningProfile: ProvisioningProfile) {
        appendProvisioningProfile.append(provisioningProfile)
        reload(isTriggeredByAppend: true)
    }

    func append(provisioningProfiles: [ProvisioningProfile]) {
        appendProvisioningProfile.append(contentsOf: provisioningProfiles)
        reload(isTriggeredByAppend: true)
    }
}
