//
//  CertificatePicker.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/20.
//

import SwiftUI
import Combine

struct CertificatePicker: View {
    @StateObject private var manager: CertificatesManager = .shared
    @Binding var certificate: Certificate?

    var body: some View {
        HStack {
            ZStack(alignment: .leading) {
                Picker("", selection: $certificate) {
                    ForEach(manager.certificates, id: \.self) {
                        // 这里必须 as Certificate? 否则和 selection Type 不匹配
                        Text($0.name).tag($0 as Certificate?)
                    }
                }.labelsHidden()

                if certificate == nil {
                    Text("Select a certificate")
                        .foregroundColor(.secondary.opacity(0.75))
                        .padding(.leading, 3)
                }
            }

            Button("↻") {
                certificate = nil
                manager.reload()
            }
        }
    }
}

struct CertificatePicker_Previews: PreviewProvider {
    static var previews: some View {
        CertificatePicker(certificate: .constant(nil))
    }
}
