//
//  ToolView.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/22.
//

import SwiftUI

struct ToolView: View {
    @StateObject var ipaTool: IPATools

    var body: some View {
        HStack {

            Spacer()

            Button("Open cache") {
                NSWorkspace.shared.open(ipaTool.workPath.deletingLastPathComponent())
            }

            Button("Reset") {
                
            }

            Button ("Start") {
                
            }
        }
    }
}

struct ToolView_Previews: PreviewProvider {
    static var previews: some View {
        ToolView(ipaTool: .init())
    }
}
