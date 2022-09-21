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
    @Binding var status: InfoViewStatus

    var body: some View {
        HStack {
            ZStack(alignment: .leading) {
                Picker("", selection: $certificate) {
                    ForEach(manager.certificates, id: \.self) { cert in
                        // 这里必须 as Certificate? 否则和 selection Type 不匹配
                        if let cert = cert {
                            Text(cert.name)
                                .tag(cert)
                        }
                    }
                }
                .labelsHidden()
                .modifier(WarningModifier($status, condition: certificate == nil))

                Text("Select a certificate")
                    .foregroundColor(.secondary.opacity(0.75))
                    .padding(.leading, 3)
                    .opacity(certificate == nil ? 1 : 0)
            }

            Button {
                manager.reload()
            } label: {
                Image("arrow.clockwise")
            }
        }
    }
}

struct CertificatePicker_Previews: PreviewProvider {
    static var previews: some View {
        CertificatePicker(certificate: .constant(nil), status: .constant(.display))
    }
}
