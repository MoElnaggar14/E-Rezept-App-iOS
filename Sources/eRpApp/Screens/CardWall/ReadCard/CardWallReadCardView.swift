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

import AVKit
import Combine
import ComposableArchitecture
import eRpStyleKit
import SwiftUI

struct CardWallReadCardView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let store: CardWallReadCardDomain.Store

    static let height: CGFloat = {
        // Compensate display scaling (Settings -> Display & Brightness -> Display -> Standard vs. Zoomed
        180 * UIScreen.main.scale / UIScreen.main.nativeScale
    }()

    @State var showVideo = false

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                // Use overlay to also fill safe area but specify fixed height
                VStack {}
                    .frame(width: nil, height: Self.height, alignment: .top)
                    .overlay(
                        HStack {
                            Image(Asset.CardWall.onScreenEgk)
                                .scaledToFill()
                                .frame(width: nil, height: Self.height, alignment: .bottom)
                        }
                    )

                Line()
                    .stroke(style: StrokeStyle(lineWidth: 2,
                                               lineCap: CoreGraphics.CGLineCap.round,
                                               lineJoin: CoreGraphics.CGLineJoin.round,
                                               miterLimit: 2,
                                               dash: [8, 8],
                                               dashPhase: 0))
                    .foregroundColor(Color(.opaqueSeparator))
                    .frame(width: nil, height: 2, alignment: .center)

                Text(L10n.cdwTxtRcPlacement)
                    .font(.subheadline.bold())
                    .foregroundColor(Color(.secondaryLabel))
                    .padding(8)
                    .padding(.bottom, 16)

                Text(L10n.cdwTxtRcCta)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding()

                Spacer(minLength: 0)

                GreyDivider()

                Button {
                    viewStore.send(viewStore.output.nextAction)
                } label: {
                    Label {
                        Text(viewStore.output.buttonTitle)
                    } icon: {
                        if !viewStore.output.nextButtonEnabled {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                    }
                }
                .buttonStyle(.primary(isEnabled: viewStore.output.nextButtonEnabled))
                .accessibility(identifier: A11y.cardWall.readCard.cdwBtnRcNext)
                .accessibility(hint: Text(L10n.cdwBtnRcNextHint))
                .padding(.vertical)

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Label(title: { Text(L10n.cdwBtnRcBack) }, icon: {})
                })
                    .buttonStyle(.secondary)
            }
            .demoBanner(isPresented: viewStore.isDemoModus) {
                Text(L10n.cdwTxtRcDemoModeInfo)
            }
            .alert(
                self.store.scope(state: \.alertState),
                dismiss: .alertDismissButtonTapped
            )
            .onAppear {
                viewStore.send(.getChallenge)
            }
        }
        .navigationBarHidden(true)
        .statusBar(hidden: true)
    }

    struct Line: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: rect.height * 0.5))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.5))
            return path
        }
    }
}

struct CardWallReadCardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView<CardWallReadCardView> {
            CardWallReadCardView(
                store: CardWallReadCardDomain.Dummies.store
            )
        }
        .previewDevice("iPhone 11")
    }
}
