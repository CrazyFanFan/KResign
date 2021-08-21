//
//  Logger.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/21.
//

import Foundation
import Combine
import AppKit

fileprivate extension String {

    var purple: NSMutableAttributedString {
        attributedString(with: .systemPurple)
    }

    var read: NSMutableAttributedString {
        attributedString(with: .red.withAlphaComponent(0.75))
    }

    var white: NSMutableAttributedString {
        attributedString(with: .white)
    }

    var yellow: NSMutableAttributedString {
        attributedString(with: .yellow.withAlphaComponent(0.75))
    }

    private func attributedString(with color: NSColor) -> NSMutableAttributedString {
        NSMutableAttributedString(string: self, attributes: [.foregroundColor: color])
    }
}

class Logger: ObservableObject {
    static let shared: Logger = .init()

    @Published var append: NSAttributedString?

    private init() {
    }
}

extension Logger {
    private static func time() -> NSMutableAttributedString {
        "[\(Formatter.date.string(from: .init()))] ".purple
    }

    static func info(_ message: String) {
        log(message.white)
    }

    static func warning(_ message: String) {
        log(message.yellow)
    }

    static func error(_ message: String, error: Error? = nil) {
        log(message.read, error?.localizedDescription.read)
    }

    private static func log(_ messages: NSAttributedString?...) {
        let tmp = time()

        for message in messages {
            if let message = message {
                tmp.append(message)
            }
        }

        tmp.append("\n".white)

        DispatchQueue.main.async {
            Logger.shared.append = tmp
        }
    }
}
