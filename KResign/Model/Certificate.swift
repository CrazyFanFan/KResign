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
    //    var append: String?

    init?(string: String) {
        var result: ParseResult?
#if swift(>=5.7.1)
        if #available(macOS 13.0, *) {
            result = Self.parseInput(string: string)
        } else {
            result = Self.parseInputOld(string: string)
        }
#else
        result = Self.parseInputOld(string: string)
#endif
        guard let result = result else {
            return nil
        }

        index = result.index
        sha1 = result.sha1
        name = result.name
        // append = result.append
    }
}

private extension Certificate {
    typealias ParseResult = (index: Int, sha1: String, name: String/*, append: String?*/)

    static func parseInputOld(string: String) -> ParseResult? {
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

        guard let indexString = getString(at: 1),
              let index = Int(indexString),
              let sha1 = getString(at: 2),
              let name = getString(at: 3) else { return nil }

        return (index, sha1, name/*, getString(at: 4)?.trimmingCharacters(in: .whitespacesAndNewlines)*/)
    }

#if swift(>=5.7.1)
    @available(macOS 13.0, *)
    static func parseInput(string: String) -> ParseResult? {
        do {
            guard let result = try /(\d+)\)\s([0-9A-Z]+)\s\"(.*)\"(.*)?/.firstMatch(in: string),
                  let index = Int(result.1) else { return nil }

            return (index, String(result.2), String(result.3)/*, result.4 == nil ? nil : String(result.4!)*/)
        } catch {
            NSLog("Certificate init match string failed. string: \(string)")
            return nil
        }
    }
#endif

}
