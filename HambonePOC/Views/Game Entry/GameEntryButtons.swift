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
        if game.isInputtingFirstDelivery {
            HStack {
                makeButton(label: "Gutter", action: {
                    game.recordDelivery(leave: Leave(Pin.allCases))
                })
                makeButton(label: leave.count == 0 ? "Strike >" : "Record >", action: {
                    game.recordDelivery(leave: leave)
                })
            }
        } else {
            HStack {
                makeButton(label: "Reset", action: {})
                makeButton(label: "Miss", action: {
                    game.recordMiss()
                    leave = []
                })
                makeButton(label: (leave.count == 0 || !game.isLeaveChanged(leave)) ?       "Spare >" : "Record >", action: {
                    if !game.isLeaveChanged(leave) {
                        game.recordDelivery(leave: [])
                    } else {
                        game.recordDelivery(leave: leave)
                    }
                    leave = []
                })
            }
        }    }
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
