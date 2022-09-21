//
//  Certificate.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/20.
//

import Foundation

let pattern = #"(\d+)\)\s([0-9A-Z]+)\s\"(.*)\"(.*)?"#
let regular: NSRegularExpression? = try? NSRegularExpression(pattern: pattern, options: [])

struct Certificate: Hashable {
    var index: Int
    var sha1: String
    var name: String
    var append: String?

    init?(string: String) {
        precondition(regular != nil, "Certificate.regular should not be nil.")

        guard let regular = regular else {
            NSLog("Certificate.regular init failed.")
            return nil
        }

        guard let match = regular.firstMatch(in: string, range: NSRange(string.startIndex..<string.endIndex, in: string)),
              match.numberOfRanges >= 4 else {
            NSLog("Certificate init match string failed. string: \(string)")
            return nil
        }

        func getString(at index: Int) -> String? {
            guard index < match.numberOfRanges, let range: Range = Range(match.range(at: index), in: string) else {
                return nil
            }
            return String(string[range])
        }

        guard let index = getString(at: 1),
              let sha1 = getString(at: 2),
              let name = getString(at: 3) else { return nil }

        self.index = Int(index) ?? 0
        self.sha1 = sha1
        self.name = name

        append = getString(at: 3)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
