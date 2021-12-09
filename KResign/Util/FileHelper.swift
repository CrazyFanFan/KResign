//
//  FileHelper.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/20.
//

import Foundation
import Combine

enum FileHelper {
    static let workPath: URL =  URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent("kResign")

    @inline(__always)
    private static var manager: FileManager { .default }

    /// 缺失的重签工具
    /// - Returns: 如果为空则表示重签依赖的工具齐全
    static func lackSupportUtility() -> [ResignDependencyTools] {
        ResignDependencyTools.allCases
            .filter { !manager.fileExists(atPath: $0.rawValue) }
    }

    static func unzip(fileAt from: URL, to target: URL) -> AnyPublisher<Bool, Error> {
        let publisher = PassthroughSubject<Bool, Error>()

        let task = Process()
        task.launchPath = ResignDependencyTools.unzip.rawValue
        task.arguments = [from.path, "-d", target.path]
        do {
            try manager.createDirectory(atPath: target.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            Logger.error("Create unzip target directory failed.", error: error)
            return Result
                .Publisher(.failure(error))
                .eraseToAnyPublisher()
        }

        DispatchQueue.global().async {
            task.launch()
            task.waitUntilExit()

            if task.terminationStatus == 0, Self.manager.fileExists(atPath: target.path) {
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
        autoreleasepool {
            let task = Process()
            task.launchPath = ResignDependencyTools.zip.rawValue
            task.currentDirectoryPath = from.path
            task.arguments = ["-qry", target.path, "."]

            DispatchQueue.global().async {
                task.launch()
                task.waitUntilExit()

                if task.terminationStatus == 0, Self.manager.fileExists(atPath: target.path) {
                    publisher.send(true)
                } else {
                    publisher.send(false)
                }
                publisher.send(completion: .finished)
            }
        }
        return publisher.eraseToAnyPublisher()
    }

    /// 路径是否存在且是文件夹
    static func isDirectoryExists(at path: String) -> Bool {
        var isDirectory: ObjCBool = .init(false)
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory), isDirectory.boolValue {
            return true
        }

        return false
    }

    static func isIpa(at path: String) -> Bool {
        var isDirectory: ObjCBool = .init(false)

        return path.hasSuffix(".ipa") &&
        FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) &&
        !isDirectory.boolValue
    }
}
