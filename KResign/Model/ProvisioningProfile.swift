//
//  ProvisioningProfile.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/20.
//

import Foundation

struct ProvisioningProfile {
    private(set) var name: String
    private(set) var teamName: String
    private(set) var isValid: Bool
    private(set) var isDebug: Bool
    private(set) var creationDate: Date
    private(set) var expirationDate: Date
    private(set) var UUID: String
    private(set) var devices: [String]
    private(set) var timeToLive: Int
    private(set) var applicationIdentifier: String
    private(set) var bundleIdentifier: String
    private(set) var certificates: [String]
    private(set) var version: Int
    private(set) var prefixes: [String]
    private(set) var appIdName: String
    private(set) var teamIdentifier: String
    private(set) var path: URL

    init?(with fileURL: URL) {
        var docoder: CMSDecoder?
        var dataRef: CFData?

        CMSDecoderCreate(&docoder)

        guard let docoder = docoder, let data = try? Data(contentsOf: fileURL) else { return nil }

        let plist: Any? = data.withUnsafeBytes { (bufferRawBufferPointer) -> Any? in

            let bufferPointer: UnsafePointer<UInt8> = bufferRawBufferPointer.baseAddress!.assumingMemoryBound(to: UInt8.self)
            let rawPtr = UnsafeRawPointer(bufferPointer)
            //USE THE rawPtr

            CMSDecoderUpdateMessage(docoder, rawPtr, data.count)
            CMSDecoderFinalizeMessage(docoder)
            CMSDecoderCopyContent(docoder, &dataRef)
            if let dataRef = dataRef,
               let plist = try? PropertyListSerialization.propertyList(
                from: dataRef as Data,
                options: [.mutableContainers],
                format: nil
               ) {
                return plist
            }

            return nil
        }

        guard let plist = plist as? [String: AnyHashable] else { return nil }

        func value<T>(for key: String) -> T? {
            if let tmp = plist[key] as? T {
                return tmp
            }

            assert(false, "Cannot read key: \(key)")
            return nil
        }

        func value<T,R>(for key: String, transfrom: (T) -> R?) -> R? {
            if let tmp = plist[key] as? T, let r = transfrom(tmp) {
                return r
            }

            assert(false, "Cannot read key: \(key)")
            return nil
        }

        func entitlementsValue<T>(for key: String) -> T? {
            if let tmp = plist["Entitlements"] as? [String: Any], let result = tmp[key] as? T {
                return result
            }

            assert(false, "Cannot read key: \(key)")
            return nil
        }

        self.appIdName = value(for: "AppIDName") ?? ""

        self.teamIdentifier = entitlementsValue(for: "com.apple.developer.team-identifier") ?? ""
        self.name = value(for: "Name") ?? ""
        self.teamName = value(for: "TeamName") ?? ""
        self.isDebug = Int(1) == entitlementsValue(for: "get-task-allow")
        self.creationDate = value(for: "CreationDate") ?? Date()
        self.expirationDate = value(for: "ExpirationDate") ?? Date()
        self.devices = value(for: "ProvisionedDevices") ?? []
        self.timeToLive =  value(for: "TimeToLive", transfrom: { (string: String) -> Int? in Int(string) }) ?? 0
        self.applicationIdentifier = entitlementsValue(for: "application-identifier") ?? ""
        self.certificates = value(for: "DeveloperCertificates") ?? []
        self.isValid = Date().timeIntervalSince(self.expirationDate) < 0
        self.version = value(for: "Version", transfrom: { (string: String) -> Int? in Int(string) }) ?? 0
        self.bundleIdentifier = self.applicationIdentifier
        self.UUID = value(for: "UUID") ?? ""
        self.prefixes = value(for: "ApplicationIdentifierPrefix") ?? []
        self.path = fileURL
    }
}
