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

import Combine
import Foundation
import Security

/// A simple implementation of an HTTP client using the interceptor concept.
public class DefaultHTTPClient: HTTPClient {
    public let interceptors: [Interceptor]
    private let urlSession: URLSession

    private weak var delegate: ProxyDelegate?

    /// Initializer for the lightweight HTTP client
    ///
    /// - Parameters:
    ///   - urlSession: `URLSessionConfiguration` that is used to create the URLSession.
    ///   - interceptors: list of `Interceptors` that may modify the request and/or response before sending.
    ///   - delegateQueue: An operation queue for scheduling the delegate calls and completion handlers.
    public init(
        urlSessionConfiguration: URLSessionConfiguration,
        interceptors: [Interceptor] = [],
        delegateQueue: OperationQueue? = nil
    ) {
        let delegate = ProxyDelegate()

        // [REQ:gemSpec_Krypt:GS-A_4385,A_18467,A_18464,GS-A_4387]
        // [REQ:gemSpec_Krypt:GS-A_5322] TODO: Check if limiting SSL Sessions is possible, check for renegotiation
        // swiftlint:disable:previous todo
        // [REQ:gemSpec_IDP_Frontend:A_20606] Live URLs not present in NSAppTransportSecurity exception list for allowed
        // HTTP communication
        // [REQ:gemSpec_eRp_FdV:A_20206]

        urlSessionConfiguration.tlsMinimumSupportedProtocolVersion = .TLSv12
        urlSession = .init(configuration: urlSessionConfiguration, delegate: delegate, delegateQueue: delegateQueue)
        self.interceptors = interceptors
        self.delegate = delegate
    }

    /// Send the given request. The request will be processed by the list of `Interceptors`.
    ///
    /// - Parameter request: The request to be (modified and) sent.
    /// - Returns: `AnyPublisher` that emits a response as `URLSessionResponse`
    public func send(
        request: URLRequest,
        interceptors requestInterceptors: [Interceptor],
        redirect handler: RedirectHandler?
    ) -> AnyPublisher<HTTPResponse, HTTPError> {
        let requestID = UUID().uuidString
        let newRequest = request.add(requestID: requestID)
        return URLRequestChain(request: newRequest, session: urlSession, with: interceptors + requestInterceptors)
            .proceed(request: newRequest)
            .handleEvents(
                receiveSubscription: { _ in self.delegate?.redirectHandler[requestID] = handler },
                receiveCompletion: { _ in self.delegate?.redirectHandler[requestID] = nil },
                receiveCancel: { self.delegate?.redirectHandler[requestID] = nil }
            )
            .eraseToAnyPublisher()
    }
}

extension URLRequest {
    func add(requestID: String) -> URLRequest {
        var modifiedRequest = self
        modifiedRequest.addValue(requestID, forHTTPHeaderField: "X-RID")
        return modifiedRequest
    }
}

extension DefaultHTTPClient {
    class ProxyDelegate: NSObject, URLSessionTaskDelegate {
        var redirectHandler = [String: RedirectHandler]()

        func urlSession(
            _: URLSession,
            task: URLSessionTask,
            willPerformHTTPRedirection response: HTTPURLResponse,
            newRequest request: URLRequest,
            completionHandler: @escaping (URLRequest?) -> Void
        ) {
            if let originalRequest = task.originalRequest,
               let requestID = originalRequest.value(forHTTPHeaderField: "X-RID"),
               let handler = redirectHandler[requestID] {
                handler(response, request, completionHandler)
            } else {
                // Follow redirect [default]
                completionHandler(request)
            }
        }
    }
}
