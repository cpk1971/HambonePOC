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
        if game.inputtingFirstDelivery {
            HStack {
                makeButton(label: "Gutter", action: {
                    game.recordDelivery(leave: Leave(Pin.allCases))
                })
                makeButton(label: "Strike", action: {
                    game.recordDelivery(leave: [])
                })
                makeButton(label: "Record >", action: {
                    game.recordDelivery(leave: leave)
                    // on the case of a strike let's reset
                    if leave.count == 0 {
                        leave = Leave.allCases
                    }
                })
            }
        } else {
            HStack {
                makeButton(label: "<", action: {})
                makeButton(label: "Miss", action: {
                    game.recordMiss()
                    leave = Leave.allCases
                })
                makeButton(label: "Spare", action: {
                    game.recordDelivery(leave: [])
                    leave = Leave.allCases
                })
                makeButton(label: "Next >", action: {
                    game.recordDelivery(leave: leave)
                    leave = Leave.allCases
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
