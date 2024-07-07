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

    func testA300Score() throws {
        var scoresheet = BowlingScoresheet()
        
        for _ in 1...12 {
            try scoresheet.recordThrow(leaving: [])
        }
        
        scoresheet.updateRunningScore()
        XCTAssertEqual(300, scoresheet.totalScore, "12 strikes should be a score of 300")
        
        for i in 1...10 {
            XCTAssertEqual(i * 30, scoresheet.frames[i-1].runningScore, "running score of frame \(i) should be \(i*30)")
        }
        
        XCTAssertTrue(scoresheet.isComplete, "this should complete the game")
        XCTAssertEqual(300, scoresheet.totalScore, "scoresheet total should be 300")
    }
    
    func testADutch200Score() throws {
        var scoresheet = BowlingScoresheet()
        
        // OK bowl a five pin, spare, then strike, five times
        for _ in 1...5 {
            try scoresheet.recordThrow(leaving: [.five])
            try scoresheet.recordThrow(leaving: [])
            try scoresheet.recordThrow(leaving: [])
        }
        
        
        // now throw the spare again
        try scoresheet.recordThrow(leaving: [.five])
        try scoresheet.recordThrow(leaving: [])
        
        scoresheet.updateRunningScore()
        XCTAssertEqual(200, scoresheet.totalScore, "Dutch 200 was expected")
        
        for i in 1...10 {
            XCTAssertEqual(i * 20, scoresheet.frames[i-1].runningScore, "running score of frame \(i) should be \(i*20)")
            XCTAssertTrue(scoresheet.frames[i-1].isComplete)
        }
        
        XCTAssertTrue(scoresheet.isComplete, "this should complete the game")
        XCTAssertEqual(200, scoresheet.totalScore, "scoresheet total should be 200")
    }
    
    func testAMoreRealisticScore() throws {
        var scoresheet = BowlingScoresheet()
        
        let someThrows : [Leave] = [
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
        
        try someThrows.forEach { try scoresheet.recordThrow(leaving: $0) }
        scoresheet.updateRunningScore()
        print(scoresheet)
        
        [9, 18, 38, 58, 78, 97, 106, 134, 153, 162].enumerated().forEach() { (i, score) in
            XCTAssertEqual(score, scoresheet.frames[i].runningScore, "frame #\(scoresheet.frames[i].number) should have running score of \(score)")
            XCTAssertTrue(scoresheet.frames[i].isComplete, "frame #\(scoresheet.frames[i].number) should be complete")
        }
        
        XCTAssertTrue(scoresheet.isComplete, "this should complete the game")
        XCTAssertEqual(162, scoresheet.totalScore, "scoresheet total should be 162")
    }
    
    func testThatStateEngineWorks() throws {
        var scoresheet = BowlingScoresheet()
        let currentFrame = scoresheet.currentFrame!
        
        XCTAssertEqual(1, currentFrame.number, "new scoresheet should start with current frame 1")
        
        let success = if case .notThrown = currentFrame.status { true } else { false }
        XCTAssertTrue(success, "first frame shouldn't be thrown")
        
        for _ in 1...10 {
            XCTAssertFalse(scoresheet.isComplete, "scoresheet shouldn't be complete yet")
            try scoresheet.recordThrow(leaving: [])
        }

        // throw the fill balls in the tenth
        try scoresheet.recordThrow(leaving: [])
        try scoresheet.recordThrow(leaving: [])
        
        XCTAssertNil(scoresheet.currentFrame, "once the game is complete, the current frame should be nil")
        XCTAssertTrue(scoresheet.isComplete, "once the game is complete, isComplete should be true")
        
        XCTAssertThrowsError(try scoresheet.recordThrow(leaving: []), "once the game is complete we can't throw anymore") { error in
            XCTAssertEqual(error as! BowlingScoresheet.Error, .gameCompleted)
        }
    }
    
    func testThatIsSplitWorks() {
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
    
    func testThatResetWorks() throws {
        var scoresheet = BowlingScoresheet()
        
        for _ in 1...12 {
            try scoresheet.recordThrow(leaving: [])
        }
  
        try scoresheet.resetGame(toFrame: 2)
        XCTAssertTrue(scoresheet.frames[0].isComplete, "frame #1 should be complete")
        for i in 1..<10 {
            XCTAssertFalse(scoresheet.frames[i].isComplete, "frame #\(i+1) should not be complete")
            let success = if case .notThrown = scoresheet.frames[i].status { true } else { false }
            XCTAssertTrue(success, "frame #\(i+1) should be thrown")
        }
        
        try scoresheet.resetGame()
        XCTAssertFalse(scoresheet.frames[0].isComplete, "frame #1 should not be complete")
        let success = if case .notThrown = scoresheet.frames[0].status { true } else { false }
        XCTAssertTrue(success, "frame #1 should be thrown")
    }
}
