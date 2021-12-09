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

    func append(other: NSAttributedString?) {
        guard let other = other else { return }

        if let old = self.append?.mutableCopy() as? NSMutableAttributedString {
            old.append(other)
            append = old
        } else {
            self.append = other
        }
    }
}

fileprivate extension String {
    func trimming() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension Logger {
    private static var isLastIsEmpty: Bool = true

    private static func time() -> NSMutableAttributedString {
        "[\(Formatter.date.string(from: .init()))] ".purple
    }

    static func preprocessor(_ message: String) -> String? {
        let message = message.trimmingCharacters(in: .whitespacesAndNewlines)

        if !message.isEmpty {
            isLastIsEmpty = false
            return message
        }

        // 跳过连续的空白行
        if isLastIsEmpty {
            return nil
        }

        return "..."
    }

    static func info(_ message: String) {
        log(preprocessor(message)?.white)
    }

    static func warning(_ message: String) {
        log(preprocessor(message)?.yellow)
    }

    static func error(_ message: String, error: Error? = nil) {
        log(preprocessor(message)?.read, error?.localizedDescription.read)
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
            Logger.shared.append(other: tmp)
        }
    }
}
