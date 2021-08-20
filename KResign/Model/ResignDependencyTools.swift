//
//  ResignDependencyTools.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/20.
//

import Foundation

enum ResignDependencyTools: String, CaseIterable {
    case zip = "/usr/bin/zip"
    case unzip = "/usr/bin/unzip"
    case codesign = "/usr/bin/codesign"
    case security = "/usr/bin/security"
}
