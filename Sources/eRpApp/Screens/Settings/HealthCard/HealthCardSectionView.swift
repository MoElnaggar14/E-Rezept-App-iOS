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

import ComposableArchitecture
import eRpStyleKit
import SwiftUI

struct HealthCardSectionView: View {
    let store: SettingsDomain.Store

    @ObservedObject
    var viewStore: ViewStore<ViewState, SettingsDomain.Action>

    init(store: SettingsDomain.Store) {
        self.store = store
        viewStore = ViewStore(self.store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let routeTag: SettingsDomain.Route.Tag?

        init(state: SettingsDomain.State) {
            routeTag = state.route?.tag
        }
    }

    var body: some View {
        SectionContainer(
            header: {
                Text(L10n.stgTxtCardSectionHeader)
            },
            content: {
                // Destination: "Order health card"
                NavigationLink(
                    destination: IfLetStore(
                        store.scope(
                            state: (\SettingsDomain.State.route)
                                .appending(path: /SettingsDomain.Route.egk)
                                .extract(from:),
                            action: SettingsDomain.Action.egkAction(action:)
                        ),
                        then: OrderHealthCardView.init(store:)
                    ),
                    tag: SettingsDomain.Route.Tag.egk,
                    selection: viewStore.binding(
                        get: \.routeTag,
                        send: SettingsDomain.Action.setNavigation
                    )
                ) {
                    Label(L10n.stgTxtCardOrderNewCard, systemImage: SFSymbolName.cardIcon)
                }
                .accessibility(identifier: A11y.settings.card.stgTxtCardOrderNewCard)
                .buttonStyle(.navigation)

                // Destination: "Forgot PIN"
                NavigationLink(
                    destination: IfLetStore(
                        store.scope(
                            state: (\SettingsDomain.State.route)
                                .appending(path: /SettingsDomain.Route.healthCardPasswordForgotPin)
                                .extract(from:),
                            action: SettingsDomain.Action.healthCardPasswordForgotPin(action:)
                        )
                    ) { scopedStore in
                        HealthCardPasswordView(store: scopedStore)
                    },
                    tag: SettingsDomain.Route.Tag.healthCardPasswordForgotPin,
                    selection: viewStore.binding(
                        get: \.routeTag,
                        send: SettingsDomain.Action.setNavigation
                    )
                ) {
                    Label(L10n.stgTxtCardForgotPin, systemImage: SFSymbolName.questionmarkCircle)
                }
                .accessibility(identifier: A11y.settings.card.stgTxtCardForgotPin)
                .buttonStyle(.navigation)

                // Destination: "Set a custom PIN"
                NavigationLink(
                    destination: IfLetStore(
                        store.scope(
                            state: (\SettingsDomain.State.route)
                                .appending(path: /SettingsDomain.Route.healthCardPasswordSetCustomPin)
                                .extract(from:),
                            action: SettingsDomain.Action.healthCardPasswordSetCustomPin(action:)
                        )
                    ) { scopedStore in
                        HealthCardPasswordView(store: scopedStore)
                    },
                    tag: SettingsDomain.Route.Tag.healthCardPasswordSetCustomPin,
                    selection: viewStore.binding(
                        get: \.routeTag,
                        send: SettingsDomain.Action.setNavigation
                    )
                ) {
                    Label(L10n.stgTxtCardCustomPin, systemImage: SFSymbolName.cardIconAnd123)
                }
                .accessibility(identifier: A11y.settings.card.stgTxtCardCustomPin)
                .buttonStyle(.navigation)

                // Destination: "Unlock health card"
                NavigationLink(
                    destination: IfLetStore(
                        store.scope(
                            state: (\SettingsDomain.State.route)
                                .appending(path: /SettingsDomain.Route.healthCardPasswordUnlockCard)
                                .extract(from:),
                            action: SettingsDomain.Action.healthCardPasswordUnlockCard(action:)
                        )
                    ) { scopedStore in
                        HealthCardPasswordView(store: scopedStore)
                    },
                    tag: SettingsDomain.Route.Tag.healthCardPasswordUnlockCard,
                    selection: viewStore.binding(
                        get: \.routeTag,
                        send: SettingsDomain.Action.setNavigation
                    )
                ) {
                    Label(L10n.stgTxtCardUnlockCard, systemImage: SFSymbolName.lockRotation)
                }
                .accessibility(identifier: A11y.settings.card.stgTxtCardUnlockCard)
                .buttonStyle(.navigation)
            }
        )
    }
}

struct HealthCardSectionView_Previews: PreviewProvider {
    static var previews: some View {
        HealthCardSectionView(store: SettingsDomain.Dummies.store)
    }
}
