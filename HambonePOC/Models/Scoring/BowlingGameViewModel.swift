//
//  BowlingGameViewModel.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-09.
//

import SwiftUI

class BowlingGameViewModel : ObservableObject {
    typealias Frame = BowlingScoresheet.Frame
    
    @Published private var model = BowlingScoresheet()
    
    var frames: [Frame] {
        model.frames
    }
    
    var currentFrameNumber: Int? {
        model.currentNumber
    }
    
    var currentFrame: Frame? {
        model.currentFrame
    }
    
    var totalScorew : Int {
        model.totalScore
    }
    
    // MARK: - Intents
}
