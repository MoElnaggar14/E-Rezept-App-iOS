//
//  Copyright (c) 2021 gematik GmbH
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

import Foundation

/// Repository error cases
public enum ErxRepositoryError<LocalError: LocalizedError, RemoteError: LocalizedError>: Swift.Error, LocalizedError,
    Equatable where LocalError: Equatable, RemoteError: Equatable {
    case local(LocalError)
    case remote(RemoteError)

    public var errorDescription: String? {
        switch self {
        case let .local(localError):
            return localError.localizedDescription
        case let .remote(remoteError):
            return remoteError.localizedDescription
        }
    }

    public static func ==(lhs: Self<LocalError, RemoteError>,
                          rhs: Self<LocalError, RemoteError>) -> Bool {
        switch (lhs, rhs) {
        case let (local(lhsError), local(rhsError)): return lhsError == rhsError
        case let (remote(lhsError), remote(rhsError)): return lhsError == rhsError
        default: return false
        }
    }
}
