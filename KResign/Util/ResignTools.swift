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
        info: [AppProvisioningProfileInfo],
        target: String
    ) {
        guard let certificate = certificate else { return }

        let launchPath = ResignDependencyTools.bash.rawValue
        var argumens = [ResignDependencyTools.resign, ipa.path, certificate.sha1]

        info.forEach {
            argumens.append("-p")
            argumens.append("\($0.bundleID)=\(($0.newProvisioning ?? $0.provisioning).path.path)")
        }

        if let version = newVersion {
            argumens.append("--short-version")
            argumens.append(version)
        }

        argumens.append(URL(fileURLWithPath: target).appendingPathComponent(ipa.lastPathComponent).path)

        run(launchPath, arguments: argumens)
            .sink { error in
                print(error)
                // TODO error
            } receiveValue: { isSuccess in
                if isSuccess {
                    print("Success")
                } else {
                    // TODO error
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

            let error = Pipe()
            task.standardError = error

            output.fileHandleForReading.readabilityHandler = { pipe in
                if let message = String(data: pipe.availableData, encoding: .utf8) {
                    Logger.info(message)
                }
            }

            error.fileHandleForReading.readabilityHandler = { pipe in
                if let message = String(data: pipe.availableData, encoding: .utf8) {
                    Logger.error(message)
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
