//
//  KRRunLoop.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/20.
//

import Foundation

class IDRunLoop {
    var isSuspend: Bool = false

    func run(_ handler: () -> Void) {
        isSuspend = false

        DispatchQueue.global().async {

        }
    }

    func stop(_ complete: () -> Void) {

    }
}
