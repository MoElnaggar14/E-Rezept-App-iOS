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

import SwiftUI

public struct InitialsImage: View {
    public init(
        backgroundColor: Color,
        text: String,
        statusColor: Color? = nil,
        borderColor: Color? = nil,
        size: Size = .regular
    ) {
        self.backgroundColor = backgroundColor
        self.text = text
        self.statusColor = statusColor
        self.borderColor = borderColor
        self.size = size
    }

    let backgroundColor: Color
    let text: String

    let statusColor: Color?
    let borderColor: Color?
    let size: Size

    public enum Size {
        case regular
        case large
        case extraLarge

        var dimension: CGFloat {
            switch self {
            case .regular: return 22
            case .large: return 32
            case .extraLarge: return 40
            }
        }

        var font: CGFloat {
            switch self {
            case .regular: return 11
            case .large: return 13
            case .extraLarge: return 17
            }
        }
    }

    public var body: some View {
        Circle()
            .fill(backgroundColor)
            .overlay(
                Circle()
                    .strokeBorder(self.borderColor ?? .clear, lineWidth: borderColor != nil ? 2 : 0)
            )
            .overlay(
                Text(text)
                    .font(.system(size: size.font).weight(.bold))
                    .foregroundColor(Color(.secondaryLabel))
            )
            .frame(width: size.dimension, height: size.dimension, alignment: .center)
            .overlay(ConnectionStatusCircle(statusColor: statusColor),
                     alignment: .bottomTrailing)
            .frame(width: 22, height: 22, alignment: .center)
    }

    struct ConnectionStatusCircle: View {
        let statusColor: Color?

        var body: some View {
            if let statusColor = statusColor {
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 12, height: 12)
                    .overlay(Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8))
            }
        }
    }
}

struct InitialsImage_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            InitialsImage(backgroundColor: Color.red, text: "AB")

            InitialsImage(
                backgroundColor: Color.green,
                text: "AB",
                statusColor: Color.red,
                borderColor: Color.blue,
                size: .large
            )

            InitialsImage(
                backgroundColor: Color.gray,
                text: "AB",
                statusColor: Color.red,
                borderColor: Color.black,
                size: .extraLarge
            )
        }
    }
}
