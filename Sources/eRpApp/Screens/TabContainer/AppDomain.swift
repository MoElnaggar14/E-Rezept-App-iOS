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

import Combine
import ComposableArchitecture
import eRpKit
import IDP
import SwiftUI

enum AppDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    enum Tab {
        case main
        case messages
    }

    struct State: Equatable {
        var selectedTab: Tab
        var main: MainDomain.State
        var messages: MessagesDomain.State
        var unreadMessagesCount: Int

        var isDemoMode: Bool
    }

    enum Action: Equatable {
        case main(action: MainDomain.Action)
        case messages(action: MessagesDomain.Action)
        case isDemoModeReceived(Bool)
        case registerDemoModeListener
        case registerUnreadMessagesListener
        case unreadMessagesReceived(Int)
        case selectTab(Tab)
    }

    struct Environment {
        let router: Routing
        var userSessionContainer: UsersSessionContainer

        var userSession: UserSession
        var schedulers: Schedulers
        var fhirDateFormatter: FHIRDateFormatter
        var serviceLocator: ServiceLocator
        let accessibilityAnnouncementReceiver: (String) -> Void

        let tracker: Tracker
        let signatureProvider: SecureEnclaveSignatureProvider
    }

    private static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .main,
             .messages:
            return .none
        case let .isDemoModeReceived(isDemoMode):
            state.isDemoMode = isDemoMode
            state.main.settingsState?.isDemoMode = isDemoMode
            return .none
        case .registerDemoModeListener:
            return environment.userSessionContainer.isDemoMode
                .map(AppDomain.Action.isDemoModeReceived)
                .eraseToEffect()
        case .registerUnreadMessagesListener:
            return environment.userSession.erxTaskRepository.countAllUnreadCommunications(for: .reply)
                .receive(on: environment.schedulers.main.animation())
                .map(AppDomain.Action.unreadMessagesReceived)
                .catch { _ in Effect.none }
                .eraseToEffect()
        case let .unreadMessagesReceived(countUnreadMessages):
            state.unreadMessagesCount = countUnreadMessages
            return .none
        case let .selectTab(tab):
            state.selectedTab = tab
            return .none
        }
    }

    private static let mainPullbackReducer: AppDomain.Reducer =
        MainDomain.reducer.pullback(
            state: \.main,
            action: /AppDomain.Action.main(action:)
        ) { appEnvironment in
            MainDomain.Environment(
                router: appEnvironment.router,
                userSessionContainer: appEnvironment.userSessionContainer,
                userSession: appEnvironment.userSessionContainer.userSession,
                appSecurityManager: appEnvironment.userSessionContainer.userSession.appSecurityManager,
                serviceLocator: appEnvironment.serviceLocator,
                accessibilityAnnouncementReceiver: appEnvironment.accessibilityAnnouncementReceiver,
                erxTaskRepository: appEnvironment.userSessionContainer.userSession.erxTaskRepository,
                schedulers: appEnvironment.schedulers,
                fhirDateFormatter: appEnvironment.fhirDateFormatter,
                signatureProvider: appEnvironment.signatureProvider,
                tracker: appEnvironment.tracker
            )
        }

    private static let messagesPullbackReducer: AppDomain.Reducer =
        MessagesDomain.reducer.pullback(
            state: \.messages,
            action: /AppDomain.Action.messages(action:)
        ) { appEnvironment in
            MessagesDomain.Environment(
                schedulers: appEnvironment.schedulers,
                erxTaskRepository: appEnvironment.userSessionContainer.userSession.erxTaskRepository,
                application: UIApplication.shared
            )
        }

    static let reducer = Reducer.combine(
        mainPullbackReducer,
        messagesPullbackReducer,
        domainReducer
    )
    .recordActionsForHints()
}

extension AppDomain {
    enum Dummies {
        static let store = Store(
            initialState: state,
            reducer: domainReducer,
            environment: environment
        )

        static let state = State(
            selectedTab: .main,
            main: MainDomain.Dummies.state,
            messages: MessagesDomain.Dummies.state,
            unreadMessagesCount: 0,
            isDemoMode: false
        )

        static let environment = Environment(
            router: DummyRouter(),
            userSessionContainer: DummyUserSessionContainer(),
            userSession: DemoSessionContainer(),
            schedulers: Schedulers(),
            fhirDateFormatter: globals.fhirDateFormatter,
            serviceLocator: ServiceLocator(),
            accessibilityAnnouncementReceiver: { _ in },
            tracker: DummyTracker(),
            signatureProvider: DummySecureEnclaveSignatureProvider()
        )
    }
}
