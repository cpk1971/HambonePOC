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
        case let .one(leave):
            // in the tenth frame, our first ball was a strike so this is effectively a "first delivery"
            inputFrameNumber == 10 && leave.count == 0
        case let .two(_, second):
            // in the tenth frame, our first two balls were strikes OR our second ball was a spare, so this is a "first delivery".
            inputFrame.number == 10 && second.count == 0
        case .three:
            false
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

