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
            ZStack(alignment: .leading) {
                Picker("", selection: $certificate) {
                    ForEach(certificates, id: \.self) {
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
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
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
