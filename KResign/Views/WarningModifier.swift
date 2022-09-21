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
        content
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(status == .warning && shouldWaring() ? Color.red : Color.clear, lineWidth: 3)
            )
    }
}
