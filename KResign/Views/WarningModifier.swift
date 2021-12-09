//
//  WarningModifier.swift
//  KResign
//
//  Created by Crazy凡 on 2021/12/8.
//

import SwiftUI

struct WarningModifier: ViewModifier {
    @Binding var status: InfoViewStatus
    var shouldWaring: () -> Bool

    init(_ status: Binding<InfoViewStatus>, condition: @autoclosure @escaping () -> Bool) {
        self._status = status
        self.shouldWaring = condition
    }

    func body(content: Content) -> some View {
        if status == .warning, shouldWaring() {
            content
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.red, lineWidth: 3)
                )
        } else {
            content
        }
    }
}
