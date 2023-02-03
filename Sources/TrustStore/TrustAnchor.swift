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

import DataKit
import Foundation
import OpenSSL

public struct TrustAnchor: Equatable {
    let certificate: X509

    // sourcery: CodedError = "562"
    public enum Error: Swift.Error {
        // sourcery: errorCode = "01"
        case invalidPEM
    }

    public init(withPEM pem: String) throws {
        guard let pem = pem.data(using: .ascii) else {
            throw Error.invalidPEM
        }
        certificate = try X509(pem: pem)
    }
}
