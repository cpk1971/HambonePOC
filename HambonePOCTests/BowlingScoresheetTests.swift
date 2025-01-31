//
//  BowlingScoresheetTests.swift
//  HambonePOCTests
//
//  Created by Charles Kincy on 2024-07-06.
//

import XCTest
@testable import HambonePOC

final class BowlingScoresheetTests: XCTestCase {
    typealias Leave = BowlingScoresheet.Leave

    func test_a_300_score() throws {
        var scoresheet = BowlingScoresheet()
        
        for _ in 1...12 {
            try scoresheet.recordDelivery(leaving: [])
        }
        
        scoresheet.updateRunningScore()
        XCTAssertEqual(300, scoresheet.totalScore, "12 strikes should be a score of 300")
        
        for i in 1...10 {
            XCTAssertEqual(i * 30, scoresheet.frames[i-1].runningScore, "running score of frame \(i) should be \(i*30)")
        }
        
        XCTAssertTrue(scoresheet.isComplete, "this should complete the game")
        XCTAssertEqual(300, scoresheet.totalScore, "scoresheet total should be 300")
    }
    
    func test_a_dutch_200_score() throws {
        var scoresheet = BowlingScoresheet()
        
        // OK bowl a five pin, spare, then strike, five times
        for _ in 1...5 {
            try scoresheet.recordDelivery(leaving: [.five])
            try scoresheet.recordDelivery(leaving: [])
            try scoresheet.recordDelivery(leaving: [])
        }
        
        
        // now bowl the spare again
        try scoresheet.recordDelivery(leaving: [.five])
        try scoresheet.recordDelivery(leaving: [])
        
        scoresheet.updateRunningScore()
        XCTAssertEqual(200, scoresheet.totalScore, "Dutch 200 was expected")
        
        for i in 1...10 {
            XCTAssertEqual(i * 20, scoresheet.frames[i-1].runningScore, "running score of frame \(i) should be \(i*20)")
            XCTAssertTrue(scoresheet.frames[i-1].isComplete)
        }
        
        XCTAssertTrue(scoresheet.isComplete, "this should complete the game")
        XCTAssertEqual(200, scoresheet.totalScore, "scoresheet total should be 200")
    }
    
    func test_a_more_realistic_score() throws {
        var scoresheet = BowlingScoresheet()
        
        let someDeliveries : [Leave] = [
            [.one, .two, .three, .five, .six, .nine, .ten],
            [.ten], // #1 3 6 = 9
            [.ten],
            [.ten], // #2 9 0 = 18
            [], // #3 X = 38
            [], // #4 X = 58
            [.one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .ten],
            [], // #5 - / = 78
            [], // #6 X = 97
            [.ten],
            [.ten], // #7 9 0 = 106
            [], // #8 X = 134
            [], // #9 X = 153
            [.seven, .ten],
            [.seven], // #10 8 1 = 162
        ]
        
        try someDeliveries.forEach { try scoresheet.recordDelivery(leaving: $0) }
        scoresheet.updateRunningScore()
        print(scoresheet)
        
        [9, 18, 38, 58, 78, 97, 106, 134, 153, 162].enumerated().forEach() { (i, score) in
            XCTAssertEqual(score, scoresheet.frames[i].runningScore, "frame #\(scoresheet.frames[i].number) should have running score of \(score)")
            XCTAssertTrue(scoresheet.frames[i].isComplete, "frame #\(scoresheet.frames[i].number) should be complete")
        }
        
        XCTAssertTrue(scoresheet.isComplete, "this should complete the game")
        XCTAssertEqual(162, scoresheet.totalScore, "scoresheet total should be 162")
    }
    
    func test_that_the_state_engine_works() throws {
        var scoresheet = BowlingScoresheet()
        let currentFrame = scoresheet.currentFrame!
        
        XCTAssertEqual(1, currentFrame.number, "new scoresheet should start with current frame 1")
        
        let success = if case .none = currentFrame.deliveries { true } else { false }
        XCTAssertTrue(success, "first frame shouldn't be thrown")
        
        for _ in 1...10 {
            XCTAssertFalse(scoresheet.isComplete, "scoresheet shouldn't be complete yet")
            try scoresheet.recordDelivery(leaving: [])
        }

        // throw the fill balls in the tenth
        try scoresheet.recordDelivery(leaving: [])
        try scoresheet.recordDelivery(leaving: [])
        
        XCTAssertNil(scoresheet.currentFrame, "once the game is complete, the current frame should be nil")
        XCTAssertTrue(scoresheet.isComplete, "once the game is complete, isComplete should be true")
        
        XCTAssertThrowsError(try scoresheet.recordDelivery(leaving: []), "once the game is complete we can't throw anymore") { error in
            XCTAssertEqual(error as! BowlingScoresheet.Error, .gameCompleted)
        }
    }
    
    func test_that_isSplit_works() {
        var it: Leave = []
        
        XCTAssertFalse(it.isSplit, "a strike is not a split")
        
        let singles: [Leave] = [
            [.one], [.two], [.three], [.four], [.five], [.six], [.seven], [.eight], [.nine], [.ten]
        ]
        
        singles.forEach{ leave in
            XCTAssertFalse(leave.isSplit, "a single pin isn't a split")
        }
        
        it = [.one, .two, .four, .ten]
        XCTAssertFalse(it.isSplit, "though annoying, the washout isn't a split")
        
        let babies: [Leave] = [
            // adjacents
            [.two, .three], [.four, .five], [.five, .six], [.seven, .eight], [.eight, .nine], [.nine, .ten],
            // one-gappers
            [.two, .seven], [.three, .ten],
        ]
        babies.forEach { leave in
            XCTAssertTrue(leave.isSplit, "the baby splits are splits")
        }

        it = [.seven, .ten]
        XCTAssertTrue(it.isSplit, "the 7-10 is a split")
        
        it = [.four, .six, .seven, .ten]
        XCTAssertTrue(it.isSplit, "the big 4 is a split")
        
        it = [.four, .six, .seven, .nine, .ten]
        XCTAssertTrue(it.isSplit, "the Greek Church is a split")

        it = [.four, .six, .seven, .eight, .ten]
        XCTAssertTrue(it.isSplit, "the other Greek Church is a split")
        
        it = [.two, .four, .six, .seven, .eight, .ten]
        XCTAssertTrue(it.isSplit, "the four-through-the-middle is a split")

        // some things that aren't splits
        let nonSplits: [Leave] = [[.three, .six, .ten], [.three, .six, .nine, .ten], [.two, .five]]
        nonSplits.forEach { leave in
            XCTAssertFalse(leave.isSplit, "none of these are splits")
        }
    }
    
    func test_that_reset_works() throws {
        var scoresheet = BowlingScoresheet()
        
        for _ in 1...12 {
            try scoresheet.recordDelivery(leaving: [])
        }
  
        try scoresheet.resetGame(toFrame: 2)
        XCTAssertTrue(scoresheet.frames[0].isComplete, "frame #1 should be complete")
        for i in 1..<10 {
            XCTAssertFalse(scoresheet.frames[i].isComplete, "frame #\(i+1) should not be complete")
            let success = if case .none = scoresheet.frames[i].deliveries { true } else { false }
            XCTAssertTrue(success, "frame #\(i+1) should be undelivered")
        }
        
        try scoresheet.resetGame()
        XCTAssertFalse(scoresheet.frames[0].isComplete, "frame #1 should not be complete")
        let success = if case .none = scoresheet.frames[0].deliveries { true } else { false }
        XCTAssertTrue(success, "frame #1 should be undelivered")
    }
}
