//
//  IPATools.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/20.
//

import Foundation
import Combine

class IPATools: ObservableObject {
    private var cancellables: [AnyCancellable] = .init()

    @Published var ipaPath: String = "" {
        didSet {
            startParse()
        }
    }

    @Published var isUnziping: Bool = false
    @Published var appInfos: [AppInfo] = []

    @inline(__always)
    private var manager: FileManager { .default }

    private var workPath: URL =  URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent("kResign")
        .appendingPathComponent("unzip")
    private var mainAppFileURL: URL?
    private var extensionsFileURLs: [URL]?

    init() {
    }

    private func unzipURL(for ipaPath: URL) -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("kResign")
            .appendingPathComponent("unzip")
            .appendingPathComponent(ipaPath.deletingPathExtension().lastPathComponent)
            .appendingPathComponent(Formatter.date.string(from: .init()).replacingOccurrences(of: "/", with: "-"))
    }

    private func startParse() {
        let source = URL(fileURLWithPath: ipaPath)
        let target = unzipURL(for: source)
        DispatchQueue.main.async {
            self.isUnziping = true
        }
        FileHelper.share.unzip(fileAt: source, to: target)
            .sink { error in
                print(error)
            } receiveValue: { [weak self] isSuccess in
                if isSuccess {
                    self?.loadApp(at: target)
                }
            }.store(in: &cancellables)
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

        let appInfos = allAppInfo.compactMap { load(from: $0, mainBundleID: info.bundleID) }

        DispatchQueue.main.async {
            self.appInfos = appInfos
            self.isUnziping = false
        }
    }

    private func load(from appRootFileURL: URL, mainBundleID: String) -> AppInfo? {
        let infoPlistURL = appRootFileURL.appendingPathComponent(BundleKey.kInfoPlistFilename)
        let bundleID: String
        if manager.fileExists(atPath: infoPlistURL.path) {
            let infoPlistDict = NSDictionary(contentsOfFile: infoPlistURL.path) as? [String: Any]
            if let tmpBundleID = infoPlistDict?[BundleKey.kCFBundleIdentifier] as? String {
                bundleID = tmpBundleID
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
            bundleID: bundleID,
            mainBundleID: mainBundleID,
            provisioning: provisioningProfile
        )
    }
}
