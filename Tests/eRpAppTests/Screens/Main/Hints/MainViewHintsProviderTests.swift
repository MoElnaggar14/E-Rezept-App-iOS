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

import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import Nimble
import XCTest

final class MainViewHintsProviderTests: XCTestCase {
    // MARK: - tests for DemoModeHint

    func testDemoModeHintWithInitialState() {
        let sut = MainViewHintsProvider()

        let hintState = HintState(hasScannedPrescriptionsBefore: true)
        let hint = sut.currentHint(for: hintState, isDemoMode: true)

        expect(hint).to(equal(MainViewHintsProvider.demoModeWelcomeHint))
    }

    func testDemoModeHintNotShowing() {
        let sut = MainViewHintsProvider()

        var hintState = HintState(hasScannedPrescriptionsBefore: true)
        hintState.hasDemoModeBeenToggledBefore = true
        let hint = sut.currentHint(for: hintState, isDemoMode: false)

        expect(hint).to(beNil())
    }
}
