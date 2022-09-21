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
    @Published var appInfos: [AppProvisioningProfileInfo] = []
    @Published var shortVersion: String = ""
    @Published var buildVersion: String = ""

    @inline(__always)
    private var manager: FileManager { .default }

    private(set) var workPath: URL =  URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent("kResign")
        .appendingPathComponent("unzip")
    private var mainAppFileURL: URL?
    private var extensionsFileURLs: [URL] = []

    init() {
        savePath = URL(fileURLWithPath: NSHomeDirectory())
            .appendingPathComponent(BundleKey.kDesktop)
            .path

        try? manager.createDirectory(atPath: workPath.path, withIntermediateDirectories: true, attributes: nil)
    }

    func isReady() -> Bool {
        isShortVersionReady() &&
        isBundleVersionReady() &&
        isIpaReady() &&
        isSavePathReady()
    }

    @inline(__always)
    func isShortVersionReady() -> Bool {
        !shortVersion.isEmpty
    }

    @inline(__always)
    func isBundleVersionReady() -> Bool {
        !buildVersion.isEmpty
    }

    @inline(__always)
    func isIpaReady() -> Bool {
        FileHelper.isIpa(at: ipaPath)
    }

    @inline(__always)
    func isSavePathReady() -> Bool {
        FileHelper.isDirectory(at: savePath)
    }
}

private extension IPATools {
    func unzipURL(for ipaPath: URL) -> URL {
        workPath
            .appendingPathComponent(ipaPath.deletingPathExtension().lastPathComponent)
            .appendingPathComponent(Formatter.date.string(from: .init()).replacingOccurrences(of: "/", with: "-"))
    }

    func startParse() {
        autoreleasepool { [unowned self] in
            let source = URL(fileURLWithPath: ipaPath)
            let target = unzipURL(for: source)
            DispatchQueue.main.async {
                self.isUnzipping = true
            }

            try? manager.removeItem(at: workPath)

            FileHelper.unzip(fileAt: source, to: target)
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

    func loadApp(at unzipFileURL: URL) {
        let payloadPath = unzipFileURL.appendingPathComponent(BundleKey.kPayloadDirName)
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

        let enumerator = manager.enumerator(atPath: mainAppFileURL.path)
        while let next = enumerator?.nextObject() {
            guard let name = next as? String,
                  name.description.hasSuffix(".app") || name.description.hasSuffix(".appex") else { continue }

            let fullURL = mainAppFileURL.appendingPathComponent(name)
            self.extensionsFileURLs.append(fullURL)
        }
        allAppInfo += extensionsFileURLs

        let info = loadInfo(from: mainAppFileURL)
        if let shortVersion = info?.shortVersion {
            DispatchQueue.main.async {
                self.shortVersion = shortVersion
            }
        }
        if let buildVersion = info?.buildVersion {
            DispatchQueue.main.async {
                self.buildVersion = buildVersion
            }
        }

        guard let bundleID = info?.bundleID else {
            // TODO error
            return
        }

        let appInfos = allAppInfo.compactMap { path in
            autoreleasepool {
                load(from: path, mainBundleID: bundleID)
            }
        }

        DispatchQueue.main.async {
            ProvisioningProfileManager.shared
                .append(provisioningProfiles: appInfos.map { $0.provisioning})

            self.appInfos = appInfos
            self.isUnzipping = false
        }
    }

    func loadInfo(from appRootFileURL: URL) -> (bundleID: String?, name: String?, shortVersion: String?, buildVersion: String?)? {
        let infoPlistURL = appRootFileURL.appendingPathComponent(BundleKey.kInfoPlistFilename)

        guard manager.fileExists(atPath: infoPlistURL.path),
              let plist = NSDictionary(contentsOfFile: infoPlistURL.path) as? [String: Any] else {
                  return nil
              }

        return (
            plist[BundleKey.kCFBundleIdentifier] as? String,
            plist[BundleKey.kCFBundleDisplayName] as? String,
            plist[BundleKey.kCFBundleShortVersionString] as? String,
            plist[BundleKey.kCFBundleVersion] as? String
        )
    }

    func loadProvisioningProfile(from appRootFileURL: URL) -> ProvisioningProfile? {
        do {
            let provisioningURL: URL? = try manager
                .contentsOfDirectory(atPath: appRootFileURL.path)
                .map { $0.lowercased() }
                .first { $0.hasSuffix("mobileprovision") || $0.hasSuffix("provisionprofile") }
                .map { appRootFileURL.appendingPathComponent($0) }

            if let provisioningURL = provisioningURL {
               return ProvisioningProfile(with: provisioningURL)
            } else {
                // TOOD error
                return nil
            }
        } catch {
            // TODO Error
            return nil
        }
    }

    func load(from appRootFileURL: URL, mainBundleID: String) -> AppProvisioningProfileInfo? {
        let info = loadInfo(from: appRootFileURL)

        guard let bundleID = info?.bundleID else {
            // TODO "Not found info.plist"
            return nil
        }

        guard let provisioningProfile = loadProvisioningProfile(from: appRootFileURL) else {
            // TODO "Not found provisioningProfile"
            return nil
        }

        let name = info?.name ?? "UnKonwn"

        return AppProvisioningProfileInfo(
            rootURL: appRootFileURL,
            name: name,
            bundleID: bundleID,
            mainBundleID: mainBundleID,
            provisioning: provisioningProfile
        )
    }
}
