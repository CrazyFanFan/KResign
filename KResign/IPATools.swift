//
//  IPATools.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/20.
//

import Combine

class IPATools: ObservableObject {
    @Published var ipaPath: String = "" {
        didSet {
            startParse()
        }
    }

    init() {
    }

    private func startParse() {

    }
}
