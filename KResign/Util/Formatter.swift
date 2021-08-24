//
//  Formatter.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/21.
//

import Foundation

enum Formatter {
    static let date: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
}
