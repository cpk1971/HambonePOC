//
//  BowlingScoresheetFrameTests.swift
//  HambonePOCTests
//
//  Created by Charles Kincy on 2024-07-05.
//

import XCTest
@testable import HambonePOC

final class BowlingScoresheetFrameTests: XCTestCase {
    func testThatAFrameReportsTheRightCompletionStatus() throws {
        var frame = Frame(number: 1)
        XCTAssertFalse(frame.isComplete, "a new frame shouldn't be complete")
        
        frame = Frame(number: 1, status: .firstBallThrown(leave: []))
        XCTAssertTrue(frame.isComplete, "a strike completes a frame")
        
        frame = Frame(number: 1, status: .firstBallThrown(leave : [.one]))
        XCTAssertFalse(frame.isComplete, "a left pin doesn't complete a frame")
        
        frame = Frame(number: 1, status: .secondBallThrown(first: [.one], second: []))
        XCTAssertTrue(frame.isComplete, "a spare completes a non-tenth frame")
        
        frame = Frame(number: 1, status: .secondBallThrown(first: [.one, .two], second: [.one]))
        XCTAssertTrue(frame.isComplete, "any second throw completes a frame")
        
        frame = Frame(number: 10, status: .firstBallThrown(leave: []))
        XCTAssertFalse(frame.isComplete, "a strike doesn't complete the tenth frame")
        
        frame = Frame(number: 10, status: .secondBallThrown(first: [.one], second: []))
        XCTAssertFalse(frame.isComplete, "a spare doesn't complete the tenth frame")
        
        frame = Frame(number: 10, status: .secondBallThrown(first: [], second: [.one]))
        XCTAssertFalse(frame.isComplete, "the first fill ball doesn't complete the tenth frame after a strike")
        
        frame = Frame(number: 10, status: .thirdBallThrown(first: [], second: [], third: []))
        XCTAssertTrue(frame.isComplete, "three balls completes the tenth frame")
        
        frame = Frame(number: 10, status: .secondBallThrown(first: [.one], second: [.one]))
        XCTAssertTrue(frame.isComplete, "an open frame completes the tenth frame")
    }
    
    func testThatFirstBallCountWorks() {
        var frame = Frame(number: 1)
        XCTAssertEqual(0, frame.firstBallCount, "unthrown frame has a count of 0")
        
        frame = Frame(number: 1, status: .firstBallThrown(leave: [.one]))
        XCTAssertEqual(9, frame.firstBallCount, "leaving one pin should have a count of nine")
        
        frame = Frame(number: 1, status: .secondBallThrown(first: [.one, .two], second: []))
        XCTAssertEqual(8, frame.firstBallCount, "eight was scored on the first ball despite the spare")
        
        frame = Frame(number: 10, status: .thirdBallThrown(first: [], second: [], third: []))
        XCTAssertEqual(10, frame.firstBallCount, "strike even on a tenth frame turkey is 10 on the first ball")
    }
    
    func testThatSecondBallCountWorks() {
        var frame = Frame(number: 1)
        XCTAssertEqual(0, frame.secondBallCount, "unthrown frame has count of 0")
        
        frame = Frame(number: 1, status: .firstBallThrown(leave: []))
        XCTAssertEqual(0, frame.secondBallCount, "no second ball on a strike so it's 0")
        
        frame = Frame(number: 1, status: .secondBallThrown(first: [.one], second: []))
        XCTAssertEqual(1, frame.secondBallCount, "9/ has a second ball count of 1")
        
        frame = Frame(number: 10, status: .thirdBallThrown(first: [], second: [], third: []))
        XCTAssertEqual(10, frame.secondBallCount, "XXX in frame 10 has a second ball count of 10")
        
        frame = Frame(number: 10, status: .thirdBallThrown(first: [.one], second: [], third: [.one]))
        XCTAssertEqual(1, frame.secondBallCount, "9/9 in frame 10 has a second ball count of 1")
    }
    
    func testThatTotalCountWorks() {
        var frame = Frame(number: 1)
        XCTAssertEqual(0, frame.totalCount, "unthrown frame has count of 0")
        
        frame = Frame(number: 1, status: .firstBallThrown(leave: []))
        XCTAssertEqual(10, frame.totalCount, "except in the 10th, a strike has a total count of ten")
        
        frame = Frame(number: 1, status: .secondBallThrown(first: [.one], second: []))
        XCTAssertEqual(10, frame.totalCount, "except in the 10th, a spare has a total count of ten")
        
        frame = Frame(number: 1, status: .secondBallThrown(first: [.one, .two], second: [.one]))
        XCTAssertEqual(9, frame.totalCount, "one pin left in the frame has a total count of 9")
        
        frame = Frame(number: 10, status: .secondBallThrown(first: [.one, .two], second: [.one]))
        XCTAssertEqual(9, frame.totalCount, "even in the tenth frame, one pin left in the frame has a total count of 9")
                
        frame = Frame(number: 10, status: .thirdBallThrown(first: [], second: [.one], third: []))
        XCTAssertEqual(20, frame.totalCount, "tenth frame throws of X/ has a count of 20")
        
        frame = Frame(number: 10, status: .thirdBallThrown(first: [.one], second: [], third: []))
        XCTAssertEqual(20, frame.totalCount, "tenth frame throws of /X has a count of 20")
        
        frame = Frame(number: 10, status: .thirdBallThrown(first: [], second: [], third: []))
        XCTAssertEqual(30, frame.totalCount, "a tenth frame 'turkey' has a count of 30")

        frame = Frame(number: 10, status: .thirdBallThrown(first: [], second: [], third: [.one]))
        XCTAssertEqual(29, frame.totalCount, "a tenth frame throw of XX9 has a count of 29")
        
        frame = Frame(number: 10, status: .thirdBallThrown(first: [.one], second: [], third: [.one]))
        XCTAssertEqual(19, frame.totalCount, "a tenth frame throw of 9/9 has a count of 19")
    }
    
    func testThatIsStrikeWorks() {
        var frame = Frame(number: 1)
        XCTAssertFalse(frame.isStrike, "an unthrown frame is not a strike")
                       
        frame = Frame(number: 1, status: .firstBallThrown(leave: []))
        XCTAssertTrue(frame.isStrike, "a frame with one throw and no remaining pins is a strike")
        
        frame = Frame(number: 1, status: .firstBallThrown(leave: [.ten]))
        XCTAssertFalse(frame.isStrike, "a frame with one throw and remaining pins is not a strike")
        
        frame = Frame(number: 1, status: .secondBallThrown(first: [.one], second: []))
        XCTAssertFalse(frame.isStrike, "a spare is not a strike")

        frame = Frame(number: 1, status: .secondBallThrown(first: [.one], second: [.one]))
        XCTAssertFalse(frame.isStrike, "an open frame is not a strike")
        
        frame = Frame(number: 10, status: .thirdBallThrown(first: [], second: [.one, .two], third: [.one]))
        XCTAssertTrue(frame.isStrike, "in the tenth frame, the first throw having no remaining pins is a strike regardless of the result of the other two balls")
    }
    
    func testThatIsSpareWorks() {
        var frame = Frame(number: 1)
        XCTAssertFalse(frame.isSpare, "an unthrown frame is not a spare")
        
        frame = Frame(number: 1, status: .firstBallThrown(leave: []))
        XCTAssertFalse(frame.isSpare, "a strike is not a spare")
        
        frame = Frame(number: 1, status: .firstBallThrown(leave: [.one]))
        XCTAssertFalse(frame.isSpare, "an incomplete frame is not a spare")
        
        frame = Frame(number: 1, status: .secondBallThrown(first: [.one], second: []))
        XCTAssertTrue(frame.isSpare, "a complete frame of two balls with no pins left is a spare")
        
        frame = Frame(number: 1, status: .secondBallThrown(first: [.one], second: [.one]))
        XCTAssertFalse(frame.isSpare, "an open frame is not a spare")
        
        frame = Frame(number: 10, status: .thirdBallThrown(first: [.one], second: [], third: []))
        XCTAssertTrue(frame.isSpare, "a spare is properly recognized in the tenth frame")
    }
    
    func testDescription() {
        XCTAssertEqual("[#10: X X X = 300]", Frame(number: 10, status: .thirdBallThrown(first: [], second: [], third: []), runningScore: 300).description, "just testing the description")
    }
    
    func testThatLineWorks() {
        XCTAssertEqual("", Frame(number: 1).line, "unthrown frame should have an empty line")
        
        XCTAssertEqual("X", Frame(number: 1, status: .firstBallThrown(leave: [])).line, "a strike should have the line 'X'")
        XCTAssertEqual("8", Frame(number: 1, status: .firstBallThrown(leave: [.six, .ten])).line, "a single 8 count should have the line '8'")
        
        XCTAssertEqual("9 /", Frame(number: 1, status: .secondBallThrown(first: [.ten], second: [])).line, "counts of 9 and 1 should have the line '9 /'")
        XCTAssertEqual("8 1", Frame(number: 1, status: .secondBallThrown(first: [.six, .ten], second: [.ten])).line, "chopping the 6 off the 6-10 should have the line '8 1'")
        
        XCTAssertEqual("X X X", Frame(number: 10, status: .thirdBallThrown(first: [], second: [], third: [])).line, "a 10th frame turkey should have the line 'X X X'")
        XCTAssertEqual("X 9 /", Frame(number: 10, status: .thirdBallThrown(first: [], second: [.ten], third: [])).line, "10th frame strike/spare should have the line 'X 9 /'")
        XCTAssertEqual("9 / X", Frame(number: 10, status: .thirdBallThrown(first: [.ten], second: [], third: [])).line, "10th frame spare/strike should have the line '9 / X'")
        XCTAssertEqual("9 / 9", Frame(number: 10, status: .thirdBallThrown(first: [.ten], second: [], third: [.ten])).line, "10th frame 9/9 should have the line '9 / 9'")
        XCTAssertEqual("X X 8", Frame(number: 10, status: .thirdBallThrown(first: [], second: [], third: [.six, .ten])).line, "a 28-count 10th frame should have the line 'X X 8")
        XCTAssertEqual("X 9 0", Frame(number: 10, status: .thirdBallThrown(first: [], second: [.ten], third: [.ten])).line, "an incomplete fill of 19 after a strike should have the line 'X 9 0")
    }
    
    func testThatRecordThrowWorks() throws {
        var frame = Frame(number: 1)
        
        try frame.recordThrow(leaving: [.ten])
        var success = if case let .firstBallThrown(leave) = frame.status, leave == [.ten] { true } else { false }
        XCTAssertTrue(success, "after a throw recorded, the frame's status reflects the throw")
        
        try frame.recordThrow(leaving: [])
        success = if case let .secondBallThrown(first, second) = frame.status, first == [.ten] && second == [] { true } else { false }
        XCTAssertTrue(success, "after a second throw recorded, the frame's status reflects the throw and correct leaves for each ball")
        
        XCTAssertThrowsError(try frame.recordThrow(leaving: []), "except in the tenth frame, a third throw is unsequenced") { error in
            XCTAssertEqual(error as! ScoresheetError, .unsequencedThrow)
        }
        
        frame = Frame(number: 1)
        try frame.recordThrow(leaving: [])
        XCTAssertThrowsError(try frame.recordThrow(leaving: []), "except in the tenth frame, a seocnd throw is unsequenced after a strike") { error in
            XCTAssertEqual(error as! ScoresheetError, .unsequencedThrow)
        }
        
        frame = Frame(number: 10)
        try frame.recordThrow(leaving: [])
        try frame.recordThrow(leaving: [])
        try frame.recordThrow(leaving: [])
        success = if case let .thirdBallThrown(first, second, third) = frame.status, first == [] && second == [] && third == [] { true } else { false }
        XCTAssertTrue(success, "three strikes are valid throws for the tenth frame")
        
        frame = Frame(number: 10)
        try frame.recordThrow(leaving: [.ten])
        try frame.recordThrow(leaving: [])
        try frame.recordThrow(leaving: [.ten])
        success = if case let .thirdBallThrown(first, second, third) = frame.status, first == [.ten] && second == [] && third == [.ten] { true } else { false }
        XCTAssertTrue(success, "spare then nine count is a valid set of throws in the tenth frame")
        
        frame = Frame(number: 10)
        try frame.recordThrow(leaving: [.ten])
        try frame.recordThrow(leaving: [.ten])
        XCTAssertThrowsError(try frame.recordThrow(leaving: []), "even in the tenth frame, a third throw after an open frame is unsequenced") { error in
            XCTAssertEqual(error as! ScoresheetError, .unsequencedThrow)
        }
    }
}
