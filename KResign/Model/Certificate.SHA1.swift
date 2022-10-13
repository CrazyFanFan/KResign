//
//  Certificate.SHA1.swift
//  KResign
//
//  Created by Crazy凡 on 2022/10/7.
//

import Foundation
import CryptoKit

private var cache: [Data: String] = [:]

enum ByteHexEncodingErrors: Error {
    case incorrectHexValue
    case incorrectString
}

let charA = UInt8(UnicodeScalar("a").value)
let char0 = UInt8(UnicodeScalar("0").value)

private func itoh(_ value: UInt8) -> UInt8 {
    return (value > 9) ? (charA + value - 10) : (char0 + value)
}

private func htoi(_ value: UInt8) throws -> UInt8 {
    switch value {
    case char0...char0 + 9:
        return value - char0
    case charA...charA + 5:
        return value - charA + 10
    default:
        throw ByteHexEncodingErrors.incorrectHexValue
    }
}

extension DataProtocol {
    var hexString: String {
        get {
            let hexLen = self.count * 2
            let ptr = UnsafeMutablePointer<UInt8>.allocate(capacity: hexLen)
            var offset = 0

            self.regions.forEach { (_) in
                for i in self {
                    ptr[Int(offset * 2)] = itoh((i >> 4) & 0xF)
                    ptr[Int(offset * 2 + 1)] = itoh(i & 0xF)
                    offset += 1
                }
            }

            return String(bytesNoCopy: ptr, length: hexLen, encoding: .utf8, freeWhenDone: true)!
        }
    }
}

extension Data {

    var sha1: String {
        if let string = cache[self] { return string }
        let result = Data(Insecure.SHA1.hash(data: self)).hexString

        cache[self] = result
        return result
    }
}
