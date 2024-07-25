//
//  GameComplete.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-25.
//

import SwiftUI

struct GameComplete: View {
    @Environment(ScoringRoot.self) var game
    
    var body: some View {
        VStack {
            Text("Game complete!").font(.largeTitle)
            GeneralAction("Save Game") {
                game.reset()
            }
            Text("but really it just resets the game").font(.caption2)
            Text("because persistence is not implemented yet)").font(.caption2)
            Text("or tap a frame to make changes")
        }.transition(.slideInFromRight)
        
    }
}

#Preview {
    GameComplete()
        .environment(ScoringRoot())
}
