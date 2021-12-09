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
            Spacer()

            Button("Open cache") {
                NSWorkspace.shared.open(ipaTool.workPath.deletingLastPathComponent())
            }

            Button("Reset") {

            }

            Button("Start", action: resign ?? {})

            if !ipaTool.appInfos.isEmpty {
                Button("Show") {
                    isPresented.toggle()
                }
            }
        }.sheet(isPresented: $isPresented) {

        } content: {
            AppProvisioningProfilesInfoView(appInfos: $ipaTool.appInfos)
                .frame(minWidth: 450)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            isPresented.toggle()
                        }
                    }
                }
        }

    }
}

struct ToolView_Previews: PreviewProvider {
    static var previews: some View {
        ToolView(ipaTool: .init())
    }
}
