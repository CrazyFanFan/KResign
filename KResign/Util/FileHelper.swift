//
//  FileHelper.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/20.
//

import Foundation
import Combine

class FileHelper {
    static let share: FileHelper = .init()

    @inline(__always)
    private var manager: FileManager { .default }

    private let provisionExtensions: [String] = ["mobileprovision", "provisionprofile"]

    private init() {
    }

    /// 缺失的重签工具
    /// - Returns: 如果为空则表示重签依赖的工具齐全
    func lackSupportUtility() -> [ResignDependencyTools] {
        ResignDependencyTools.allCases
            .filter { !manager.fileExists(atPath: $0.rawValue) }
    }

    func readCertificates() -> AnyPublisher<[Certificate], Error> {
        let task = Process()
        task.launchPath = ResignDependencyTools.security.rawValue
        task.arguments = ["find-identity", "-v", "-p", "codesigning"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        let handle = pipe.fileHandleForReading
        task.launch()

        let publisher = PassthroughSubject<[Certificate], Error>()

        DispatchQueue.global().async {
            let securityResult: Data?
            do {
                securityResult = try handle.readToEnd()
            } catch {
                publisher.send(completion: .failure(error))
                return
            }

            guard let data = securityResult,
                  let securityString = String(data: data, encoding: .utf8),
                  !securityString.isEmpty else {
                publisher.send(completion: .failure(FileHelperError.filedToReadSecurity))
                return
            }

            var rawResult = securityString.components(separatedBy: "\n")
            rawResult.removeLast()
            let certificates = rawResult.compactMap { Certificate(string: $0) }

            if certificates.isEmpty {
                publisher.send(completion: .failure(FileHelperError.noSignignCertificates))
            } else {
                publisher.send(certificates)
                publisher.send(completion: .finished)
            }
        }

        return publisher.eraseToAnyPublisher()
    }

    func getProvisioningProfiles() -> [ProvisioningProfile] {
        let path = "\(NSHomeDirectory().components(separatedBy: "/Library")[0])/Library/MobileDevice/Provisioning Profiles"
        return ((try? manager.contentsOfDirectory(atPath: path)) ?? [])
            .map { "\(path)/\($0)" }
            .filter { manager.fileExists(atPath: $0) } // 确认文件存在
            .map { URL(fileURLWithPath: $0) } // 转成URL
            .filter { provisionExtensions.contains($0.pathExtension.lowercased()) } // 确认文件扩展名
            .compactMap { ProvisioningProfile(with: $0) }
            // 转换成功
    }

    func unzip(fileAt from: URL, to target: URL) -> AnyPublisher<Bool, Error> {

        let publisher = PassthroughSubject<Bool, Error>()

        let task = Process()
        task.launchPath = ResignDependencyTools.unzip.rawValue
        task.arguments = [from.path, "-d", target.path]

        DispatchQueue.global().async { [unowned self] in
            task.launch()
            task.waitUntilExit()

            if task.terminationStatus == 0, self.manager.fileExists(atPath: target.path) {
                publisher.send(true)
            } else {
                publisher.send(false)
            }
            publisher.send(completion: .finished)
        }

        return publisher.eraseToAnyPublisher()
    }

    func zip(fileAt from: URL, to target: URL) -> AnyPublisher<Bool, Error> {

        let publisher = PassthroughSubject<Bool, Error>()

        let task = Process()
        task.launchPath = ResignDependencyTools.zip.rawValue
        task.currentDirectoryPath = from.path
        task.arguments = ["-qry", target.path, "."]

        DispatchQueue.global().async { [unowned self] in
            task.launch()
            task.waitUntilExit()

            if task.terminationStatus == 0, self.manager.fileExists(atPath: target.path) {
                publisher.send(true)
            } else {
                publisher.send(false)
            }
            publisher.send(completion: .finished)
        }

        return publisher.eraseToAnyPublisher()
    }
}
