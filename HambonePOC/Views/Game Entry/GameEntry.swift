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
                    GameEntryButtons(leave: $leave)
                }
            }
        }
    }
}

#Preview {
    GameEntry()
        .environment(ScoringRoot())
}
