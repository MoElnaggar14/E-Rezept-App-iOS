//
//  Copyright (c) 2022 gematik GmbH
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

import SwiftUI

struct PrescriptionHintView: View {
    var title: String?
    var message: String?
    var imageName: String?

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 120)
                    .foregroundColor(Colors.separator)
                    .font(.title3)
                    .padding(.leading)
                    .padding(.top, 16)
            }

            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    if let title = title {
                        Text(title)
                            .font(Font.subheadline.weight(.semibold))
                            .foregroundColor(Colors.text)
                    }
                    if let message = message {
                        Text(message)
                            .font(Font.subheadline)
                            .foregroundColor(Colors.text)
                            .padding(.top, 4)
                            .padding(.bottom, 8)
                            .layoutPriority(1)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical)

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .border(Colors.separator,
                width: 0.5,
                cornerRadius: 16)
    }
}
