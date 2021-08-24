//
//  ResultSavePathPicker.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/22.
//

import SwiftUI

struct ResultSavePathPicker: View {
    @Binding var path: String

    var body: some View {
        HStack {
            TextField("Pick a directory to save resigned ipa.", text: $path)
            Button("Browser") {
                picker()
            }
        }
    }

    private func picker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.allowsOtherFileTypes = false

        if panel.runModal() == .OK, let url = panel.urls.last {
            self.path = url.path
        }
    }
}

struct ResultSavePathPicker_Previews: PreviewProvider {
    static var previews: some View {
        ResultSavePathPicker(path: .constant(""))
    }
}
