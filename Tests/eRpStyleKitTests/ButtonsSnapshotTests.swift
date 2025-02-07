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

import eRpStyleKit
import SnapshotTesting
import SwiftUI
import XCTest

final class ButtonsSnapshotTests: XCTestCase {
    override class func setUp() {
        super.setUp()

        diffTool = "open"
    }

    func testButtons() {
        let sut = VStack(alignment: .leading, spacing: 16) {
            Spacer()

            Group {
                Text("Primary")
                    .padding(.leading)

                Button {} label: {
                    Label(title: { Text("Button") }, icon: {})
                }
                .buttonStyle(.primary(isEnabled: true, isDestructive: false))

                Button {} label: {
                    Label(title: { Text("Button") }, icon: {})
                }
                .buttonStyle(.primary(isEnabled: false, isDestructive: false))

                Button {} label: {
                    Label(title: { Text("Button") }, icon: { Image(systemName: SFSymbolName.bag) })
                }
                .buttonStyle(.primary(isEnabled: true, isDestructive: false))

                Button {} label: {
                    Label(title: { Text("Button") }, icon: { Image(systemName: SFSymbolName.bag) })
                }
                .buttonStyle(.primary(isEnabled: false, isDestructive: false))
            }

            Group {
                Text("Secondary")
                    .padding(.leading)

                Button {} label: {
                    Label(title: { Text("Button") }, icon: {})
                }
                .buttonStyle(.secondary(isEnabled: true, isDestructive: false))

                Button {} label: {
                    Label(title: { Text("Button") }, icon: {})
                }
                .buttonStyle(.secondary(isEnabled: false, isDestructive: false))

                Button {} label: {
                    Label(title: { Text("Button") }, icon: { Image(systemName: SFSymbolName.bag) })
                }
                .buttonStyle(.secondary(isEnabled: true, isDestructive: false))

                Button {} label: {
                    Label(title: { Text("Button") }, icon: { Image(systemName: SFSymbolName.bag) })
                }
                .buttonStyle(.secondary(isEnabled: false, isDestructive: false))
            }

            Group {
                Text("Tertiary")
                    .padding(.leading)

                Button {} label: {
                    Label(title: { Text("Button") }, icon: {})
                }
                .buttonStyle(.tertiary(isEnabled: true, isDestructive: false))

                Button {} label: {
                    Label(title: { Text("Button") }, icon: {})
                }
                .buttonStyle(.tertiary(isEnabled: false, isDestructive: false))

                Button {} label: {
                    Label(title: { Text("Button") }, icon: { Image(systemName: SFSymbolName.bag) })
                }
                .buttonStyle(.tertiary(isEnabled: true, isDestructive: false))

                Button {} label: {
                    Label(title: { Text("Button") }, icon: { Image(systemName: SFSymbolName.bag) })
                }
                .buttonStyle(.tertiary(isEnabled: false, isDestructive: false))
            }

            Spacer()
        }
        .font(.footnote)
        .foregroundColor(Color(.secondaryLabel))
        .background(Color(.systemBackground))
        .frame(width: 375)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testDestructiveButtons() {
        let sut = VStack(alignment: .leading, spacing: 16) {
            Spacer()

            Group {
                Text("Primary")
                    .padding(.leading)

                Button {} label: {
                    Label(title: { Text("Button") }, icon: {})
                }
                .buttonStyle(.primary(isEnabled: true, isDestructive: true))

                Button {} label: {
                    Label(title: { Text("Button") }, icon: {})
                }
                .buttonStyle(.primary(isEnabled: false, isDestructive: true))

                Button {} label: {
                    Label(title: { Text("Button") }, icon: { Image(systemName: SFSymbolName.bag) })
                }
                .buttonStyle(.primary(isEnabled: true, isDestructive: true))

                Button {} label: {
                    Label(title: { Text("Button") }, icon: { Image(systemName: SFSymbolName.bag) })
                }
                .buttonStyle(.primary(isEnabled: false, isDestructive: true))
            }

            Group {
                Text("Secondary")
                    .padding(.leading)

                Button {} label: {
                    Label(title: { Text("Button") }, icon: {})
                }
                .buttonStyle(.secondary(isEnabled: true, isDestructive: true))

                Button {} label: {
                    Label(title: { Text("Button") }, icon: {})
                }
                .buttonStyle(.secondary(isEnabled: false, isDestructive: true))

                Button {} label: {
                    Label(title: { Text("Button") }, icon: { Image(systemName: SFSymbolName.bag) })
                }
                .buttonStyle(.secondary(isEnabled: true, isDestructive: true))

                Button {} label: {
                    Label(title: { Text("Button") }, icon: { Image(systemName: SFSymbolName.bag) })
                }
                .buttonStyle(.secondary(isEnabled: false, isDestructive: true))
            }

            Group {
                Text("Tertiary")
                    .padding(.leading)

                Button {} label: {
                    Label(title: { Text("Button") }, icon: {})
                }
                .buttonStyle(.tertiary(isEnabled: true, isDestructive: true))

                Button {} label: {
                    Label(title: { Text("Button") }, icon: {})
                }
                .buttonStyle(.tertiary(isEnabled: false, isDestructive: true))

                Button {} label: {
                    Label(title: { Text("Button") }, icon: { Image(systemName: SFSymbolName.bag) })
                }
                .buttonStyle(.tertiary(isEnabled: true, isDestructive: true))

                Button {} label: {
                    Label(title: { Text("Button") }, icon: { Image(systemName: SFSymbolName.bag) })
                }
                .buttonStyle(.tertiary(isEnabled: false, isDestructive: true))
            }

            Spacer()
        }
        .font(.footnote)
        .foregroundColor(Color(.secondaryLabel))
        .background(Color(.systemBackground))
        .frame(width: 375)

        assertSnapshots(matching: sut, as: snapshotModi())
    }
}
