//
//  ContentView.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/20.
//

import Foundation
import AppKit
import SwiftUI

struct ContentView: View {
    @StateObject var logger: Logger = Logger.shared
    @StateObject var ipaTool = IPATools()
    @StateObject private var certificatesManager: CertificatesManager = .shared

    @State private var certificate: Certificate?

    @State private var status: InfoViewStatus = .display

    var body: some View {
        ZStack {
            VStack {
                Group {
                    IPAPicker(path: $ipaTool.ipaPath, status: $status)
                    Divider()

                    ResultSavePathPicker(path: $ipaTool.savePath, status: $status)
                    Divider()

                    CertificatePicker(certificate: $certificate, status: $status)
                    Divider()

                    VersionPicker(
                        version: $ipaTool.shortVersion,
                        buildVersion: $ipaTool.buildVersion,
                        status: $status
                    )
                    Divider()

                    AppProvisioningProfilesGroupView(
                        appInfos: $ipaTool.appInfos
                    )
                }

                LogView(append: $logger.append)
                    .frame(height: 180)
            }
            .touchBar {
                ToolView(ipaTool: ipaTool, resign: resign)
            }
            .toolbar {
                ToolView(ipaTool: ipaTool, resign: resign)
            }

            if ipaTool.isUnzipping || certificatesManager.isLoading {
                ProgressView(ipaTool.isUnzipping ? "Unzipping" : "Loading")
                    .progressViewStyle(.circular)
            }
        }
        .padding()
        .frame(minWidth: 650, maxWidth: 900, alignment: .topLeading)
        .disabled(ipaTool.isUnzipping)
    }

    @inline(__always)
    private func isReady() -> Bool {
        certificate != nil && ipaTool.isReady()
    }

    private func resign() {
        if isReady() {
            ResignTools.resign(
                ipa: URL(fileURLWithPath: ipaTool.ipaPath),
                with: certificate,
                newVersion: ipaTool.shortVersion,
                buildVersion: ipaTool.buildVersion,
                info: ipaTool.appInfos,
                target: ipaTool.savePath
            )
        } else {
            withAnimation(.linear(duration: 0.3).repeatCount(3)) {
                status = .warning
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                status = .display
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
