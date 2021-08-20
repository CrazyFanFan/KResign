//
//  ContentView.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/20.
//

import SwiftUI

struct ContentView: View {
    @StateObject var ipaTool = IPATools()
    @State var certificate: Certificate?

    var body: some View {
        VStack {
            IPAPicker(path: $ipaTool.ipaPath)
            CertificatePicker(certificate: $certificate)
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
