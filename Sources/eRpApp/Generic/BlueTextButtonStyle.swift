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

struct BlueTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(10)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 22)
            .foregroundColor(Color.white)
            .opacity(configuration.isPressed ? 0.25 : 1)
            .animation(.easeInOut(duration: 0.1))
            .background(Colors.primary)
            .cornerRadius(8)
    }
}

struct BlueTextButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: {},
               label: {
                   Text("Blue Button Style")
               })
            .buttonStyle(BlueTextButtonStyle())
    }
}
