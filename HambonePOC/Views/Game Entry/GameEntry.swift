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
    
    @State var leave:  Leave = []
    
    @Environment(ScoringRoot.self) var game
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollViewReader { svrProxy in
            VStack {
                Text("Hambone!").font(.largeTitle)
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach(1...10, id: \.self) { i in
                            Frame(frame: game.frames[i-1], 
                                  isInputFrame: i == game.currentFrameNumber)
                                .zIndex(i == game.currentFrameNumber ? 1 : 0)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .onChange(of: game.currentFrameNumber) { _, new in
                    withAnimation {
                        if let new {
                            svrProxy.scrollTo(new, anchor: .center)
                        }
                    }
                    
                }
                if game.isComplete {
                    VStack {
                        GameComplete()
                    }.transition(.slideInFromRight)
                } else {
                    VStack {
                        Rack(pins: $leave, previousPins: game.previousDelivery).padding([.top, .bottom], 20)
                        GameEntryButtons(leave: $leave)
                    }.transition(.slideInFromRight)
                }
                Spacer()
            }
        }
    }
}

#Preview {
    GameEntry()
        .environment(ScoringRoot())
}
