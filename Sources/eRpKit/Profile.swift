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

import Foundation

/// Represents a user profile selectable within the settings
public struct Profile: Identifiable, Hashable, Equatable {
    public init(
        name: String,
        identifier: UUID = UUID(),
        created: Date = Date(),
        givenName: String? = nil,
        familyName: String? = nil,
        insurance: String? = nil,
        insuranceId: String? = nil,
        color: Color = Color.next(),
        emoji: String? = nil,
        lastAuthenticated: Date? = nil,
        erxTasks: [ErxTask] = []
    ) {
        self.name = name
        self.identifier = identifier
        self.created = created
        self.givenName = givenName
        self.familyName = familyName
        self.insurance = insurance
        self.insuranceId = insuranceId
        self.color = color
        self.emoji = emoji
        self.lastAuthenticated = lastAuthenticated
        self.erxTasks = erxTasks
    }

    public var id: UUID { // swiftlint:disable:this identifier_name
        identifier
    }

    public var name: String
    public let identifier: UUID
    public let created: Date
    public var givenName: String?
    public var familyName: String?
    public var insurance: String?
    public var insuranceId: String?
    public var color: Color
    public var emoji: String?
    public var lastAuthenticated: Date?
    public var erxTasks: [ErxTask]

    public var fullName: String? {
        [givenName, familyName]
            .compactMap { $0 }
            .joined(separator: " ")
    }

    public enum Color: String, CaseIterable {
        case grey
        case yellow
        case red
        case green
        case blue

        static var lastUsedColor: Color?

        public static func next() -> Color {
            guard let lastColor = Self.lastUsedColor,
                  let index = Self.allCases.firstIndex(of: lastColor) else {
                let newColor = Self.random()
                Self.lastUsedColor = newColor
                return newColor
            }

            let isLastColor = index == Self.allCases.endIndex - 1
            let nextColor = Self.allCases[isLastColor ? Self.allCases.startIndex : index.advanced(by: 1)]
            Self.lastUsedColor = nextColor
            return nextColor
        }

        private static func random() -> Color {
            var generator = SystemRandomNumberGenerator()
            return Color.random(using: &generator)
        }

        private static func random<G: RandomNumberGenerator>(using generator: inout G) -> Color {
            Color.allCases.randomElement(using: &generator) ?? .grey
        }
    }
}
