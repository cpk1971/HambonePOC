//
//  GameEntry.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-22.
//

import SwiftUI

struct GameEntry: View {
    typealias Pin = BowlingScoresheet.Pin
    typealias Leave = BowlingScoresheet.Leave
    
    @State var leave:  Leave = Leave(Pin.allCases)
    
    @Environment(ScoringRoot.self) var game
    @Environment(\.colorScheme) var colorScheme
    
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
        ScrollViewReader { svrProxy in
            VStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach(1...10, id: \.self) { i in
                            Frame(frame: game.frames[i-1], isInputFrame: i == game.inputFrameNumber)
                        }
                    }
                }.onChange(of: game.inputFrameNumber) { _, new in
                    withAnimation {
                        if let new {
                            svrProxy.scrollTo(new, anchor: .center)
                        }
                    }
                    
                }
                if let _ = game.inputFrameNumber {
                    Rack(pins: $leave).padding([.top, .bottom], 20)
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
                    }
                }
            }
        }
    }
}

#Preview {
    GameEntry()
        .environment(ScoringRoot())
}
