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
    
    var currentFrameNumber: Int? {
        scoresheet.currentNumber
    }
    
    var currentFrame: Frame? {
        scoresheet.currentFrame
    }
    
    var frames: [Frame] {
        scoresheet.frames
    }
    
    // MARK: - State exposures
    
    var isComplete: Bool {
        // scoresheet.isComplete
        scoresheet.currentNumber == nil
    }
    
    func isFrameSelectable(_ number: Int) -> Bool {
        scoresheet.isFrameSelectable(number)
    }
    
    /// this is a hard-to-describe concept, but by "first delivery" we mean the first delivery in frames 1-9 and any
    /// throw at a full rack in the tenth frame.  We call it "first delivery" rather than "throw at a full rack"
    /// because that's the term of art in the sport of bowling, but in the tenth frame it means any situation where
    /// we are throwing at a full rack.
    var isInputtingFirstDelivery: Bool {
        guard let currentFrame else {
            return false
        }
        
        return switch currentFrame.deliveries {
        case .none:
            true
        case let .one(leave):
            // in the tenth frame, our first ball was a strike so this is effectively a "first delivery"
            currentFrameNumber == 10 && leave.count == 0
        case let .two(_, second):
            // in the tenth frame, our first two balls were strikes OR our second ball was a spare, so this is a "first delivery".
            currentFrame.number == 10 && second.count == 0
        case .three:
            false
        }
    }
    
    func isLeaveChanged(_ leave: Leave) -> Bool {
        leave != previousDelivery
    }
    
    /// when we're making a shot at a partial rack we need to know what was left so we can hide input
    /// buttons on the spare entry.  This is "nil" at all other times.
    var previousDelivery: Leave? {
        guard let currentFrame else {
            return nil
        }
        
        return if currentFrame.number < 10 {
            switch currentFrame.deliveries {
            case .none, .two, .three: nil
            case let .one(leave): leave
            }
        } else {
            switch currentFrame.deliveries {
            case .none, .three: nil
            case let .one(leave): currentFrame.isStrike ? nil : leave
            case let .two(_, leave): currentFrame.isSpare ? nil : leave
            }
        }
    }
    
    // MARK: - Intents
    
    func recordDelivery(leave: Leave) {
        do {
            try scoresheet.recordDelivery(leaving: leave)
        } catch {
            // FIXME: not yet sure what to do here
            print(error)
        }
        scoresheet.updateRunningScore()
    }
    
    func recordMiss() {
        // FIXME: some error handling?
        guard let currentFrame else { return }
        
        switch currentFrame.deliveries {
        case .none:
            // this is a gutter ball obviously
            recordDelivery(leave: Leave.allCases)
        case let .one(leave), let .two(_, leave):
            // leave the same pins
            recordDelivery(leave: leave)
        case .three:
            return
        }
    }
    
    func reset() {
        scoresheet.resetGame()
    }
    
    func resetForEditing(frameNumber: Int) {
        // FIXME: is ignore on error best?
        guard frameNumber >= 1 && frameNumber <= 10 else { return }
        
        do {
            _ = try scoresheet.resetFrame(number: frameNumber)
        } catch {
           /// ???
        }
    }
}

