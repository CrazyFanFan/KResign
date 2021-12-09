//
//  IPAPicker.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/20.
//

import SwiftUI

struct IPAPicker: View {
    @Binding var path: String
    @Binding var status: InfoViewStatus

    var body: some View {
        HStack {
            TextField("Pick an ipa file.", text: $path)
                .modifier(WarningModifier(status: $status, shouldWaring: !FileHelper.isIpa(at: path)))
            Button("Browser") {
                picker()
            }
        }
    }

    private func picker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowsOtherFileTypes = false
        panel.allowedFileTypes = ["IPA"]

        if panel.runModal() == .OK, let url = panel.urls.last {
            self.path = url.path
        }
    }
}

struct IPAPicker_Previews: PreviewProvider {
    static var previews: some View {
        IPAPicker(path: .constant(""), status: .constant(.display))
    }
}
