//
//  CertificatesManager.swift
//  CertificatesManager
//
//  Created by Crazy凡 on 2021/8/24.
//

import Foundation
import Combine

class CertificatesManager: ObservableObject {
    static let shared: CertificatesManager = .init()

    @inline(__always)
    private var manager: FileManager { .default }
    private var cancellable: AnyCancellable?

    @Published var certificates: [Certificate] = []

    private init() {
        reload()  // call reload to load init data.
    }

    func reload() {
        cancellable = readCertificates()
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { error in
                print(error)
            } receiveValue: { certificates in
                self.certificates = certificates
            }
    }

    private func readCertificates() -> AnyPublisher<[Certificate], Error> {
        let task = Process()
        task.launchPath = ResignDependencyTools.security.rawValue
        task.arguments = ["find-identity", "-v", "-p", "codesigning"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        let handle = pipe.fileHandleForReading
        task.launch()

        let publisher = PassthroughSubject<[Certificate], Error>()
        Logger.info("Start: read certificates")

        DispatchQueue.global().async {
            let securityResult: Data?
            do {
                securityResult = try handle.readToEnd()
            } catch {
                DispatchQueue.main.async {
                    Logger.error("Read certificates error.", error: error)
                }
                publisher.send(completion: .failure(error))
                return
            }

            guard let data = securityResult,
                  let securityString = String(data: data, encoding: .utf8),
                  !securityString.isEmpty else {
                Logger.error("Read certificates failed.")
                publisher.send(completion: .failure(KResignError.filedToReadSecurity))
                return
            }

            let certStrings = securityString
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: "\n")

            let certificates = certStrings
                .prefix(certStrings.count - 1)
                .compactMap { Certificate(string: $0) }

            if certificates.isEmpty {
                Logger.warning("Certificates count is zero.")

                publisher.send(completion: .failure(KResignError.noSignignCertificates))
            } else {
                publisher.send(certificates)
                publisher.send(completion: .finished)
                Logger.info("End: read certificates.")
            }
        }

        return publisher.eraseToAnyPublisher()
    }
}
