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
    
    private var scoresheet = BowlingScoresheet()
    var inputFrameNumber = 1
    
    var inputFrame: Frame {
        scoresheet.frames[inputFrameNumber - 1]
    }
}

