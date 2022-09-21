//
//  ResignTools.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/24.
//

import Foundation
import Combine

enum ResignTools {
    @inline(__always)
    private static var manager: FileManager { .default }

    private static var set: Set<AnyCancellable> = .init()

    static func resign(
        ipa: URL,
        with certificate: Certificate?,
        newVersion: String?,
        buildVersion: String? = nil,
        info: [AppProvisioningProfileInfo],
        target: String
    ) {
        guard let certificate = certificate else {
            Logger.error("Miss certificate", error: nil)
            return
        }

        let launchPath = ResignDependencyTools.bash.rawValue
        var argumens = [ResignDependencyTools.resign, ipa.path, certificate.sha1]

        info.forEach {
            argumens.append("-p")
            argumens.append("\($0.bundleID)=\($0.newProvisioning.path.path)")
        }

        if let version = newVersion {
            argumens.append("--short-version")
            argumens.append(version)
        }

        if let buildVersion = buildVersion {
            argumens.append("--bundle-version")
            argumens.append(buildVersion)
        }

        argumens.append(URL(fileURLWithPath: target).appendingPathComponent(ipa.lastPathComponent).path)

        run(launchPath, arguments: argumens)
            .sink { result in
                switch result {
                case .failure(let error):
                    Logger.error("Resign failed with error.", error: error)
                case .finished:
                    break
                }
            } receiveValue: { isSuccess in
                if isSuccess {
                    Logger.info("Resign success")
                } else {
                    Logger.info("Resign failed.")
                }
            }.store(in: &set)
    }

    private static func check(ipa fileURL: URL?) -> Bool {
        guard let path = fileURL?.path else { return false }
        guard manager.fileExists(atPath: path) else { return false }

        return true
    }

    private static func run(_ launchPath: String, arguments: [String]) -> AnyPublisher<Bool, Error> {
        let publisher = PassthroughSubject<Bool, Error>()
        autoreleasepool {
            let task = Process()
            task.launchPath = launchPath
            task.currentDirectoryURL =  URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("kResign")
            task.arguments = arguments

            let output = Pipe()
            task.standardOutput = output
            task.standardError = output

            output.fileHandleForReading.readabilityHandler = { pipe in
                if let message = String(data: pipe.availableData, encoding: .utf8) {
                    Logger.info(message)
                }
            }

            DispatchQueue.global().async {
                task.launch()
                task.waitUntilExit()

                if task.terminationStatus == 0 {
                    publisher.send(true)
                } else {
                    publisher.send(false)
                }
                publisher.send(completion: .finished)
            }
        }
        return publisher.eraseToAnyPublisher()
    }
}
