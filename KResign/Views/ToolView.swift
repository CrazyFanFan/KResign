//
//  ToolView.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/22.
//

import SwiftUI

struct ToolView: View {
    typealias Handler = () -> Void
    @StateObject var ipaTool: IPATools

    @State private var isPresented: Bool = false

    var resign: Handler?
    var reset: Handler?

    var body: some View {
        HStack {
            Button("Open cache") {
                NSWorkspace.shared.open(ipaTool.workPath.deletingLastPathComponent())
            }

            Button("Start", action: resign ?? {})
        }
        .sheet(isPresented: $isPresented) {

        } content: {

        }
    }
}

struct ToolView_Previews: PreviewProvider {
    static var previews: some View {
        ToolView(ipaTool: .init())
    }
}
