//
//  IPATools.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/20.
//

import Foundation
import Combine
import SwiftUI

class IPATools: ObservableObject {
    private var cancellables: [AnyCancellable] = .init()

    @Published var savePath: String
    @Published var ipaPath: String = "" {
        didSet {
            startParse()
        }
    }

    @Published var isUnzipping: Bool = false
    @Published var appInfos: [AppInfo] = []

    @inline(__always)
    private var manager: FileManager { .default }

    private(set) var workPath: URL =  URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent("kResign")
        .appendingPathComponent("unzip")
    private var mainAppFileURL: URL?
    private var extensionsFileURLs: [URL]?

    init() {
        savePath = URL(fileURLWithPath: NSHomeDirectory())
            .appendingPathComponent(BundleKey.kDesktop)
            .path

        try? manager.createDirectory(atPath: workPath.path, withIntermediateDirectories: true, attributes: nil)
    }

    private func unzipURL(for ipaPath: URL) -> URL {
        workPath
            .appendingPathComponent(ipaPath.deletingPathExtension().lastPathComponent)
            .appendingPathComponent(Formatter.date.string(from: .init()).replacingOccurrences(of: "/", with: "-"))
    }

    private func startParse() {
        autoreleasepool { [unowned self] in
            let source = URL(fileURLWithPath: ipaPath)
            let target = unzipURL(for: source)
            DispatchQueue.main.async {
                self.isUnzipping = true
            }

            try? manager.removeItem(at: workPath)

            FileHelper.share.unzip(fileAt: source, to: target)
                .sink { error in
                    print(error)
                } receiveValue: { [weak self] isSuccess in
                    if isSuccess {
                        autoreleasepool {
                            self?.loadApp(at: target)
                        }
                    }
                }.store(in: &cancellables)
        }
    }

    private func loadApp(at path: URL) {
        let payloadPath = path.appendingPathComponent(BundleKey.kPayloadDirName)
        let content: [String]
        do {
            content = try manager.contentsOfDirectory(atPath: payloadPath.path)
        } catch {
            Logger.error("Get app path failed.", error: error)
            return
        }

        guard let appName = content.first(where: { $0.hasSuffix("app") }) else {
            // TODO error log
            return
        }

        // store all app or appx paths.
        var allAppInfo: [URL] = []

        let mainAppFileURL = payloadPath.appendingPathComponent(appName)
        allAppInfo.append(mainAppFileURL)

        self.mainAppFileURL = mainAppFileURL

        let pluginsDir = mainAppFileURL.appendingPathComponent(BundleKey.kPlugIns)

        if manager.fileExists(atPath: pluginsDir.path) {
            let appx: [String]
            do {
                appx = try manager.contentsOfDirectory(atPath: pluginsDir.path)
            } catch {
                appx = []
                Logger.error("Get appx path failed.", error: error)
            }

            let extensionsAppFileURLs = appx.map { pluginsDir.appendingPathComponent($0) }
            self.extensionsFileURLs = extensionsAppFileURLs

            allAppInfo += extensionsAppFileURLs
        }

        // todo main
        let info = load(from: mainAppFileURL, mainBundleID: "")!

        let appInfos = allAppInfo.compactMap { path in
            autoreleasepool {
                load(from: path, mainBundleID: info.bundleID)
            }
        }

        DispatchQueue.main.async {
            ProvisioningProfileManager.shared
                .append(provisioningProfiles: appInfos.map { $0.provisioning})

            self.appInfos = appInfos
            self.isUnzipping = false
        }
    }

    private func load(from appRootFileURL: URL, mainBundleID: String) -> AppInfo? {
        let infoPlistURL = appRootFileURL.appendingPathComponent(BundleKey.kInfoPlistFilename)
        let bundleID: String
        let name: String
        if manager.fileExists(atPath: infoPlistURL.path) {
            let infoPlistDict = NSDictionary(contentsOfFile: infoPlistURL.path) as? [String: Any]
            if let tmpBundleID = infoPlistDict?[BundleKey.kCFBundleIdentifier] as? String {
                bundleID = tmpBundleID
                name = infoPlistDict?[BundleKey.kCFBundleDisplayName] as? String ?? "UnKonwn"
            } else {
                // TODO "Not found info.plist"
                return nil
            }
        } else {
            // TODO "Not found info.plist"
            return nil
        }

        let provisioningProfile: ProvisioningProfile
        do {
            let provisioningURL: URL? = try manager
                .contentsOfDirectory(atPath: appRootFileURL.path)
                .map { $0.lowercased() }
                .first { $0.hasSuffix("mobileprovision") || $0.hasSuffix("provisionprofile") }
                .map { appRootFileURL.appendingPathComponent($0) }

            if let provisioningURL = provisioningURL,
               let tmpProvisioningProfile = ProvisioningProfile(with: provisioningURL) {
                provisioningProfile = tmpProvisioningProfile
            } else {
                // TOOD error
                return nil
            }
        } catch {
            // TODO Error
            return nil
        }

        return AppInfo(
            rootURL: appRootFileURL,
            name: name,
            bundleID: bundleID,
            mainBundleID: mainBundleID,
            provisioning: provisioningProfile
        )
    }
}
