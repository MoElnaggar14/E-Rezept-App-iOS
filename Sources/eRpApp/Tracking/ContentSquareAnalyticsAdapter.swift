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
import ContentsquareModule
import Foundation
import UIKit

final class ContentSquareAnalyticsAdapter: NSObject, Tracker {
    let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
        super.init()

        startIfPermitted()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(eraseSessionID(notification:)),
            name: UIScene.didDisconnectNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    var optIn: Bool {
        get {
            userDefaults.appTrackingAllowed
        }
        set {
            userDefaults.appTrackingAllowed = newValue
            if newValue {
                // [REQ:gemSpec_eRp_FdV:A_19090] activate after optIn is granted
                Contentsquare.start()
                Contentsquare.optIn()
            } else {
                Contentsquare.optOut()
            }
        }
    }

    var optInPublisher: AnyPublisher<Bool, Never> {
        userDefaults.publisher(for: \UserDefaults.appTrackingAllowed)
            .eraseToAnyPublisher()
    }

    /// Starts tracking and calls `optIn` if permission is granted by the user.
    /// Calling this method after calling `resetSessionID()` will create a new `sessionID`
    // [REQ:gemSpec_eRp_FdV:A_19090] activate tracking only if permitted
    private func startIfPermitted() {
        if optIn {
            Contentsquare.start()
            Contentsquare.optOut()
            Contentsquare.optIn()
        }
    }

    /// Erases the `sessionID`.  The combination of calling this method with
    /// calling `startIfPermitted` will guarantee that a new `sessionID` is generated
    @objc
    private func eraseSessionID(notification _: Notification) {
        // [REQ:gemSpec_eRp_FdV:A_19095] resets sessionID so that on next app start a new sessionID will be created
        Contentsquare.optOut()
    }

    func track(events: [AnalyticsEvent]) {
        if optIn {
            for event in events {
                Contentsquare.send(dynamicVar: .init(key: event, value: event))
            }
        }
    }

    func track(screens: [AnalyticsScreen]) {
        if optIn {
            for screen in screens {
                Contentsquare.send(screenViewWithName: screen.name)
            }
        }
    }

    func track(event: String) {
        if optIn {
            Contentsquare.send(dynamicVar: .init(key: event, value: event))
        }
    }

    func track(screen: String) {
        if optIn {
            Contentsquare.send(screenViewWithName: screen)
        }
    }

    func stopTracking() {
        optIn = false
        Contentsquare.optOut()
    }
}
