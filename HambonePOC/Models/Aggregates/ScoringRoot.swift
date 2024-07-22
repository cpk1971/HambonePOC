//
//  ScoringRoot.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-22.
//

import Foundation
import Observation

@Observable
class ScoringRoot {
    typealias Frame = BowlingScoresheet.Frame
    typealias Leave = BowlingScoresheet.Leave
    
    private var scoresheet = BowlingScoresheet()
    var inputFrameNumber = 1
    
    var inputFrame: Frame {
        scoresheet.frames[inputFrameNumber - 1]
    }
    
    var frames: [Frame] {
        scoresheet.frames
    }
    
    /// this is a hard-to-describe concept, but by "first delivery" we mean the first delivery in frames 1-9 and any
    /// throw at a full rack in the tenth frame.  We call it "first delivery" rather than "throw at a full rack"
    /// because that's the term of art in the sport of bowling, but in the tenth frame it means any situation where
    /// we are throwing at a full rack.
    var inputtingFirstDelivery: Bool {
        switch inputFrame.deliveries {
        case .none:
            true
        case .one:
            false
        case let .two(first, _):
            // in the tenth frame, our first ball was a strike so this is effectively a "first delivery"
            inputFrame.number == 10 && first.count == 0
        case let .three(_, second, _):
            // if all pins were felled on the second ball of the tenth, it's either that we have a double or
            // we covered a spare.  Either way we're shooting at a full rack with the third ball, so it counts
            // as "first delivery".  We'll never get a "second" one, though.
            inputFrameNumber == 10 && second.count == 0
        }
    }
    
    // MARK: - Intents
    
    func recordDelivery(leave: Leave) {
        // FIXME: add logic around inputting a different game than we're actually on
        try! scoresheet.recordDelivery(leaving: leave)
        scoresheet.updateRunningScore()
        // FIXME: this will crash unless we figure out how to change previous deliveries
        inputFrameNumber = scoresheet.currentNumber ?? 10
    }
}

