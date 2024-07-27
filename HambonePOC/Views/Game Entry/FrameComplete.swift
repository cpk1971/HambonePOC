//
//  FrameComplete.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-26.
//

import SwiftUI

struct FrameComplete: View {
    @Environment(ScoringRoot.self) var game
    var frameNumber: Int

    var body: some View {
        VStack {
            Text("Frame complete!").font(.largeTitle)
            GeneralAction("Reset Frame") {
                game.reset()
            }
        }.transition(.slideInFromRight)
    }
}

#Preview {
    FrameComplete(frameNumber: 1).environment(ScoringRoot())
}
