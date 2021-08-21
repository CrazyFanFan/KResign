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
    @State private var provisioningProfile: ProvisioningProfile?

    @State private var log: NSAttributedString?
    @State private var log2: String = ""

    var body: some View {
        VStack {
            IPAPicker(path: $ipaTool.ipaPath)
            CertificatePicker(certificate: $certificate)
            ProvisioningProfilePicker(provisioningProfile: $provisioningProfile)
            LogView(append: $logger.append)
                .frame(minHeight: 100)
        }
        .padding()
        .frame(minWidth: 550, minHeight: 350, alignment: .topLeading)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
