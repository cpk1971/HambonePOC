//
//  GameEntryButtons.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-23.
//

import SwiftUI

struct GameEntryButtons: View {
    typealias Leave = BowlingScoresheet.Leave
    typealias Pin = BowlingScoresheet.Pin
    
    @Environment(ScoringRoot.self) var game
    @Environment(\.colorScheme) var colorScheme
    @Binding var leave: Leave
    
    func makeButton(label: String,
                    action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.title3)
                .padding()
                .foregroundColor(.green)
                .background(colorScheme.neutralReverseColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.green, lineWidth: 2)
                )
        }
    }
    
    var body: some View {
        VStack {
            if game.isInputtingFirstDelivery {
                HStack {
                    GeneralAction("Gutter", action: {
                        game.recordDelivery(leave: Leave(Pin.allCases))
                    })
                    Spacer()
                    GeneralAction(leave.count == 0 ? "Strike >" : "Record >", action: {
                        withAnimation {
                            game.recordDelivery(leave: leave)
                        }
                    })
                }
                .transition(.slideInFromRight)
                .padding(30)
            } else {
                HStack {
                    GeneralAction("Reset") {
                        
                    }
                    Spacer().frame(width: 30)
                    GeneralAction("Miss") {
                        game.recordMiss()
                        leave = []
                    }
                    Spacer()
                    GeneralAction(leave.count == 0 || !game.isLeaveChanged(leave)
                                  ? "Spare >" : "Record >") {
                        withAnimation {
                            if !game.isLeaveChanged(leave) {
                                game.recordDelivery(leave: [])
                            } else {
                                game.recordDelivery(leave: leave)
                            }
                            leave = []
                        }
                    }
                }
                .transition(.slideInFromRight)
                .padding(30)
            }
        }
    }
}

#Preview {
    PreviewWrapper().environment(ScoringRoot())
}

fileprivate struct PreviewWrapper : View {
    typealias Leave = BowlingScoresheet.Leave
    @State var leave: Leave = Leave.allCases
    
    var body : some View {
        GameEntryButtons(leave: $leave)
    }
}
