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
    @State private var certificate: Certificate?
    @State private var log: NSAttributedString?
    @State private var log2: String = ""

    var body: some View {
        ZStack {
            VStack {
                IPAPicker(path: $ipaTool.ipaPath)
                ResultSavePathPicker(path: $ipaTool.savePath)

                CertificatePicker(certificate: $certificate)

                AppInfosView(appInfos: $ipaTool.appInfos)

                LogView(append: $logger.append)
                    .frame(minHeight: 100)
            }
            if ipaTool.isUnzipping {
                ActivityIndicator().frame(width: 100, height: 100, alignment: .center)
            }
        }
        .padding()
        .frame(minWidth: 750, minHeight: 350, alignment: .topLeading)
        .disabled(ipaTool.isUnzipping)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
