//
//  Copyright (c) 2023 gematik GmbH
//  
//  Licensed under the EUPL, Version 1.2 or – as soon they will be approved by
//  the European Commission - subsequent versions of the EUPL (the Licence);
//  You may not use this work except in compliance with the Licence.
//  You may obtain a copy of the Licence at:
//  
//      https://joinup.ec.europa.eu/software/page/eupl
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the Licence for the specific language governing permissions and
//  limitations under the Licence.
//  
//

import CoreImage.CIFilterBuiltins
import SwiftUI

#if ENABLE_DEBUG_VIEW

struct DebugQRCodeExporter<ContentType: Codable>: View {
    var content: ContentType

    @State
    var image: UIImage?

    @State
    var error: String?

    @State
    var showShareSheet = false

    var body: some View {
        ScrollView {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding()

                Button("Share") {
                    showShareSheet = true
                }
            } else {
                ProgressView()
            }
            TextEditor(text: .constant(error ?? ""))
                .font(.system(.body, design: .monospaced))
                .padding()
                .background(Colors.systemBackgroundSecondary)
                .padding()
                .introspectTextView { textView in
                    textView.backgroundColor = UIColor.secondarySystemBackground
                }
        }
        .navigationTitle("Export")
        .sheet(isPresented: $showShareSheet) {
            if let image = image {
                ShareViewController(itemsToShare: [image])
            }
        }
        .onAppear {
            DispatchQueue.global().async {
                let encoder = JSONEncoder()
                guard let data = try? encoder.encode(content) else {
                    error = "encoding"
                    return
                }
                encoder.outputFormatting = .prettyPrinted

                if let visualData = try? encoder.encode(content) {
                    error = String(data: visualData, encoding: .utf8)
                }

                let context = CIContext()
                let filter = CIFilter.qrCodeGenerator()
                filter.message = data
                let transform = CGAffineTransform(scaleX: 4, y: 4)

                if let output = filter.outputImage?.transformed(by: transform),
                   let cgimg = context.createCGImage(output, from: output.extent) {
                    let image = UIImage(cgImage: cgimg)
                    DispatchQueue.main.async {
                        self.image = image
                    }
                } else {
                    error = "Could not generate Image, possibly to much data"
                }
            }
        }
    }
}

struct DebugQRCodeImporterExporter_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DebugQRCodeExporter(content:
                DebugPharmacy(
                    name: "myname",
                    onPremiseUrl: .init(url: "https://gematik.de"),
                    shipmentUrl: .init(url: "https://gematik.de"),
                    deliveryUrl: .init(url: "https://gematik.de"),
                    certificates: []
                ))
        }
    }
}

#endif
