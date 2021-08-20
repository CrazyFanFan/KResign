//
//  CertificatePicker.swift
//  KResign
//
//  Created by Crazy凡 on 2021/8/20.
//

import SwiftUI
import Combine

struct CertificatePicker: View {
    static var handler: AnyCancellable?
    @Binding var certificate: Certificate?
    @State private var certificates: [Certificate] = []
    
    var body: some View {
        HStack {
            Picker("Select a certificate: ", selection: $certificate) {
                ForEach(certificates, id: \.self) {
                    Text($0.name).tag($0 as Certificate?) // 这里必须 as Certificate? 否则和 selection Type 不匹配
                }
            }

            Button("↻") {
                reloadCertificates()
            }
        }
        .onAppear(perform: {
            reloadCertificates()
        })
    }

    private func reloadCertificates() {
        certificate = nil

        CertificatePicker.handler = FileHelper.share.readCertificates()
            .sink { error in
                print(error)
            } receiveValue: { certificates in
                self.certificates = certificates
            }
    }
}

struct CertificatePicker_Previews: PreviewProvider {
    static var previews: some View {
        CertificatePicker(certificate: .constant(nil))
    }
}
