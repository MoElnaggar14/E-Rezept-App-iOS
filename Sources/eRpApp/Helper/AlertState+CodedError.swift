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

import ComposableArchitecture

extension AlertState {
    init(for error: CodedError, title: StringAsset, primaryButton: Button? = nil) {
        self.init(for: error, title: TextState(title), primaryButton: primaryButton)
    }

    // body length will be shorter with dropped iOS 14 support
    // swiftlint:disable:next function_body_length
    init(for error: CodedError, title: TextState? = nil, primaryButton: Button? = nil, secondaryButton: Button? = nil) {
        let resultTitle: TextState
        let resultDescription: TextState

        if let title = title {
            resultTitle = title
            resultDescription = TextState(error.descriptionAndSuggestionWithErrorList)
        } else {
            if error.recoverySuggestion != nil {
                resultTitle = TextState(error.localizedDescription)
                resultDescription = TextState(error.recoverySuggestionWithErrorList)
            } else {
                resultTitle = TextState(L10n.errTitleGeneric)
                resultDescription = TextState(error.localizedDescriptionWithErrorList)
            }
        }

        if #available(iOS 15, *) {
            let buttons: [AlertState<Action>.Button]
            if let primaryButton = primaryButton {
                if let secondaryButton = secondaryButton {
                    buttons = [
                        primaryButton,
                        secondaryButton,
                    ]
                } else {
                    buttons = [
                        .cancel(TextState(L10n.alertBtnOk)),
                        primaryButton,
                    ]
                }
            } else {
                buttons = [.cancel(TextState(L10n.alertBtnOk))]
            }
            self.init(
                title: resultTitle,
                message: resultDescription,
                buttons: buttons
            )
        } else {
            if let primaryButton = primaryButton {
                if let secondaryButton = secondaryButton {
                    self.init(
                        title: resultTitle,
                        message: resultDescription,
                        primaryButton: primaryButton,
                        secondaryButton: secondaryButton
                    )
                } else {
                    self.init(
                        title: resultTitle,
                        message: resultDescription,
                        primaryButton: primaryButton,
                        secondaryButton: .cancel(TextState(L10n.errBtnCancel))
                    )
                }
            } else {
                self.init(
                    title: title ?? TextState(L10n.errTitleGeneric),
                    message: TextState(error.localizedDescriptionWithErrorList),
                    dismissButton: .cancel(TextState(L10n.alertBtnOk))
                )
            }
        }
    }
}

enum ErpAlertState<Action: Equatable>: Equatable {
    static func ==(lhs: ErpAlertState<Action>, rhs: ErpAlertState<Action>) -> Bool {
        switch (lhs, rhs) {
        case let (.info(lhsv), .info(rhsv)),
             let (.error(_, lhsv), .error(_, rhsv)):
            return lhsv == rhsv
        default:
            return false
        }
    }

    case info(AlertState<Action>)
    case error(error: CodedError, alertState: AlertState<Action>)

    var alert: AlertState<Action> {
        switch self {
        case let .info(alert):
            return alert
        case let .error(_, alertState):
            return alertState
        }
    }

    init(for error: CodedError, title: StringAsset) {
        self.init(for: error, title: TextState(title.key))
    }

    init(_ info: AlertState<Action>) {
        self = .info(info)
    }

    init(
        for error: CodedError,
        title: StringAsset,
        primaryButton: AlertState<Action>.Button? = nil,
        secondaryButton: AlertState<Action>.Button? = nil
    ) {
        self.init(
            for: error,
            title: TextState(title.key),
            primaryButton: primaryButton,
            secondaryButton: secondaryButton
        )
    }

    init(
        for error: CodedError,
        title: TextState? = nil,
        primaryButton: AlertState<Action>.Button? = nil,
        secondaryButton: AlertState<Action>.Button? = nil
    ) {
        self = .error(
            error: error,
            alertState: .init(for: error, title: title, primaryButton: primaryButton, secondaryButton: secondaryButton)
        )
    }

    init(
        title: TextState,
        message: TextState? = nil,
        dismissButton: AlertState<Action>.Button? = nil
    ) {
        self = .info(.init(title: title, message: message, dismissButton: dismissButton))
    }

    init(
        title: TextState,
        message: TextState? = nil,
        primaryButton: AlertState<Action>.Button,
        secondaryButton: AlertState<Action>.Button
    ) {
        self = .info(.init(
            title: title,
            message: message,
            primaryButton: primaryButton,
            secondaryButton: secondaryButton
        ))
    }
}

import SwiftUI

extension View {
    /// Displays an alert when then store's state becomes non-`nil`, and dismisses it when it becomes
    /// `nil`.
    ///
    /// - Parameters:
    ///   - store: A store that describes if the alert is shown or dismissed.
    ///   - dismissal: An action to send when the alert is dismissed through non-user actions, such
    ///     as when an alert is automatically dismissed by the system. Use this action to `nil` out
    ///     the associated alert state.
    @ViewBuilder func alert<Action>(
        _ store: Store<ErpAlertState<Action>?, Action>,
        dismiss: Action
    ) -> some View {
        alert(store.scope { $0?.alert }, dismiss: dismiss)
    }
}
