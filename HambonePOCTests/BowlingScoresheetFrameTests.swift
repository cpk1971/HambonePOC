//
//  BowlingScoresheetFrameTests.swift
//  HambonePOCTests
//
//  Created by Charles Kincy on 2024-07-05.
//

import XCTest
@testable import HambonePOC

final class BowlingScoresheetFrameTests: XCTestCase {
    typealias Frame = BowlingScoresheet.Frame
    typealias ScoresheetError = BowlingScoresheet.Error
    typealias Leave = BowlingScoresheet.Leave

    func testThatAFrameReportsTheRightCompletiondeliveries() throws {
        var frame = Frame(number: 1)
        XCTAssertFalse(frame.isComplete, "a new frame shouldn't be complete")
        
        frame = Frame(number: 1, deliveries: .one(leave: []))
        XCTAssertTrue(frame.isComplete, "a strike completes a frame")
        
        frame = Frame(number: 1, deliveries: .one(leave : [.one]))
        XCTAssertFalse(frame.isComplete, "a left pin doesn't complete a frame")
        
        frame = Frame(number: 1, deliveries: .two(first: [.one], second: []))
        XCTAssertTrue(frame.isComplete, "a spare completes a non-tenth frame")
        
        frame = Frame(number: 1, deliveries: .two(first: [.one, .two], second: [.one]))
        XCTAssertTrue(frame.isComplete, "any second delivery completes a frame")
        
        frame = Frame(number: 10, deliveries: .one(leave: []))
        XCTAssertFalse(frame.isComplete, "a strike doesn't complete the tenth frame")
        
        frame = Frame(number: 10, deliveries: .two(first: [.one], second: []))
        XCTAssertFalse(frame.isComplete, "a spare doesn't complete the tenth frame")
        
        frame = Frame(number: 10, deliveries: .two(first: [], second: [.one]))
        XCTAssertFalse(frame.isComplete, "the first fill ball doesn't complete the tenth frame after a strike")
        
        frame = Frame(number: 10, deliveries: .three(first: [], second: [], third: []))
        XCTAssertTrue(frame.isComplete, "three balls completes the tenth frame")
        
        frame = Frame(number: 10, deliveries: .two(first: [.one], second: [.one]))
        XCTAssertTrue(frame.isComplete, "an open frame completes the tenth frame")
    }
    
    func testThatFirstBallCountWorks() {
        var frame = Frame(number: 1)
        XCTAssertEqual(0, frame.firstBallCount, "undelivered frame has a count of 0")
        
        frame = Frame(number: 1, deliveries: .one(leave: [.one]))
        XCTAssertEqual(9, frame.firstBallCount, "leaving one pin should have a count of nine")
        
        frame = Frame(number: 1, deliveries: .two(first: [.one, .two], second: []))
        XCTAssertEqual(8, frame.firstBallCount, "eight was scored on the first ball despite the spare")
        
        frame = Frame(number: 10, deliveries: .three(first: [], second: [], third: []))
        XCTAssertEqual(10, frame.firstBallCount, "strike even on a tenth frame turkey is 10 on the first ball")
    }
    
    func testThatSecondBallCountWorks() {
        var frame = Frame(number: 1)
        XCTAssertEqual(0, frame.secondBallCount, "undelivered frame has count of 0")
        
        frame = Frame(number: 1, deliveries: .one(leave: []))
        XCTAssertEqual(0, frame.secondBallCount, "no second ball on a strike so it's 0")
        
        frame = Frame(number: 1, deliveries: .two(first: [.one], second: []))
        XCTAssertEqual(1, frame.secondBallCount, "9/ has a second ball count of 1")
        
        frame = Frame(number: 10, deliveries: .three(first: [], second: [], third: []))
        XCTAssertEqual(10, frame.secondBallCount, "XXX in frame 10 has a second ball count of 10")
        
        frame = Frame(number: 10, deliveries: .three(first: [.one], second: [], third: [.one]))
        XCTAssertEqual(1, frame.secondBallCount, "9/9 in frame 10 has a second ball count of 1")
    }
    
    func testThatTotalCountWorks() {
        var frame = Frame(number: 1)
        XCTAssertEqual(0, frame.totalCount, "undelivered frame has count of 0")
        
        frame = Frame(number: 1, deliveries: .one(leave: []))
        XCTAssertEqual(10, frame.totalCount, "except in the 10th, a strike has a total count of ten")
        
        frame = Frame(number: 1, deliveries: .two(first: [.one], second: []))
        XCTAssertEqual(10, frame.totalCount, "except in the 10th, a spare has a total count of ten")
        
        frame = Frame(number: 1, deliveries: .two(first: [.one, .two], second: [.one]))
        XCTAssertEqual(9, frame.totalCount, "one pin left in the frame has a total count of 9")
        
        frame = Frame(number: 10, deliveries: .two(first: [.one, .two], second: [.one]))
        XCTAssertEqual(9, frame.totalCount, "even in the tenth frame, one pin left in the frame has a total count of 9")
                
        frame = Frame(number: 10, deliveries: .three(first: [], second: [.one], third: []))
        XCTAssertEqual(20, frame.totalCount, "tenth frame deliveries of X/ has a count of 20")
        
        frame = Frame(number: 10, deliveries: .three(first: [.one], second: [], third: []))
        XCTAssertEqual(20, frame.totalCount, "tenth frame deliveries of /X has a count of 20")
        
        frame = Frame(number: 10, deliveries: .three(first: [], second: [], third: []))
        XCTAssertEqual(30, frame.totalCount, "a tenth frame 'turkey' has a count of 30")

        frame = Frame(number: 10, deliveries: .three(first: [], second: [], third: [.one]))
        XCTAssertEqual(29, frame.totalCount, "a tenth frame delivery of XX9 has a count of 29")
        
        frame = Frame(number: 10, deliveries: .three(first: [.one], second: [], third: [.one]))
        XCTAssertEqual(19, frame.totalCount, "a tenth frame delivery of 9/9 has a count of 19")
    }
    
    func testThatIsStrikeWorks() {
        var frame = Frame(number: 1)
        XCTAssertFalse(frame.isStrike, "an undelivered frame is not a strike")
                       
        frame = Frame(number: 1, deliveries: .one(leave: []))
        XCTAssertTrue(frame.isStrike, "a frame with one delivery and no remaining pins is a strike")
        
        frame = Frame(number: 1, deliveries: .one(leave: [.ten]))
        XCTAssertFalse(frame.isStrike, "a frame with one delivery and remaining pins is not a strike")
        
        frame = Frame(number: 1, deliveries: .two(first: [.one], second: []))
        XCTAssertFalse(frame.isStrike, "a spare is not a strike")

        frame = Frame(number: 1, deliveries: .two(first: [.one], second: [.one]))
        XCTAssertFalse(frame.isStrike, "an open frame is not a strike")
        
        frame = Frame(number: 10, deliveries: .three(first: [], second: [.one, .two], third: [.one]))
        XCTAssertTrue(frame.isStrike, "in the tenth frame, the first delivery having no remaining pins is a strike regardless of the result of the other two balls")
    }
    
    func testThatIsSpareWorks() {
        var frame = Frame(number: 1)
        XCTAssertFalse(frame.isSpare, "an undelivered frame is not a spare")
        
        frame = Frame(number: 1, deliveries: .one(leave: []))
        XCTAssertFalse(frame.isSpare, "a strike is not a spare")
        
        frame = Frame(number: 1, deliveries: .one(leave: [.one]))
        XCTAssertFalse(frame.isSpare, "an incomplete frame is not a spare")
        
        frame = Frame(number: 1, deliveries: .two(first: [.one], second: []))
        XCTAssertTrue(frame.isSpare, "a complete frame of two balls with no pins left is a spare")
        
        frame = Frame(number: 1, deliveries: .two(first: [.one], second: [.one]))
        XCTAssertFalse(frame.isSpare, "an open frame is not a spare")
        
        frame = Frame(number: 10, deliveries: .three(first: [.one], second: [], third: []))
        XCTAssertTrue(frame.isSpare, "a spare is properly recognized in the tenth frame")
    }
    
    func testDescription() {
        XCTAssertEqual("[#10: X X X = 300]", Frame(number: 10, deliveries: .three(first: [], second: [], third: []), runningScore: 300).description, "just testing the description")
    }
    
    func testThatLineWorks() {
        XCTAssertEqual("", Frame(number: 1).line, "undelivered frame should have an empty line")
        
        XCTAssertEqual("X", Frame(number: 1, deliveries: .one(leave: [])).line, "a strike should have the line 'X'")
        XCTAssertEqual("8", Frame(number: 1, deliveries: .one(leave: [.six, .ten])).line, "a single 8 count should have the line '8'")
        
        XCTAssertEqual("9 /", Frame(number: 1, deliveries: .two(first: [.ten], second: [])).line, "counts of 9 and 1 should have the line '9 /'")
        XCTAssertEqual("8 1", Frame(number: 1, deliveries: .two(first: [.six, .ten], second: [.ten])).line, "chopping the 6 off the 6-10 should have the line '8 1'")
        
        XCTAssertEqual("X X X", Frame(number: 10, deliveries: .three(first: [], second: [], third: [])).line, "a 10th frame turkey should have the line 'X X X'")
        XCTAssertEqual("X 9 /", Frame(number: 10, deliveries: .three(first: [], second: [.ten], third: [])).line, "10th frame strike/spare should have the line 'X 9 /'")
        XCTAssertEqual("9 / X", Frame(number: 10, deliveries: .three(first: [.ten], second: [], third: [])).line, "10th frame spare/strike should have the line '9 / X'")
        XCTAssertEqual("9 / 9", Frame(number: 10, deliveries: .three(first: [.ten], second: [], third: [.ten])).line, "10th frame 9/9 should have the line '9 / 9'")
        XCTAssertEqual("X X 8", Frame(number: 10, deliveries: .three(first: [], second: [], third: [.six, .ten])).line, "a 28-count 10th frame should have the line 'X X 8")
        XCTAssertEqual("X 9 0", Frame(number: 10, deliveries: .three(first: [], second: [.ten], third: [.ten])).line, "an incomplete fill of 19 after a strike should have the line 'X 9 0")
    }
    
    func testThatRecordDeliveryWorks() throws {
        var frame = Frame(number: 1)
        
        try frame.recordDelivery(leaving: [.ten])
        var success = if case let .one(leave) = frame.deliveries, leave == [.ten] { true } else { false }
        XCTAssertTrue(success, "after a delivery recorded, the frame's deliveries reflects the delivery")
        
        try frame.recordDelivery(leaving: [])
        success = if case let .two(first, second) = frame.deliveries, first == [.ten] && second == [] { true } else { false }
        XCTAssertTrue(success, "after a second delivery recorded, the frame's deliveries reflects the delivery and correct leaves for each ball")
        
        XCTAssertThrowsError(try frame.recordDelivery(leaving: []), "except in the tenth frame, a third delivery is unsequenced") { error in
            XCTAssertEqual(error as! ScoresheetError, .unsequencedDelivery)
        }
        
        frame = Frame(number: 1)
        try frame.recordDelivery(leaving: [])
        XCTAssertThrowsError(try frame.recordDelivery(leaving: []), "except in the tenth frame, a seocnd delivery is unsequenced after a strike") { error in
            XCTAssertEqual(error as! ScoresheetError, .unsequencedDelivery)
        }
        
        frame = Frame(number: 10)
        try frame.recordDelivery(leaving: [])
        try frame.recordDelivery(leaving: [])
        try frame.recordDelivery(leaving: [])
        success = if case let .three(first, second, third) = frame.deliveries, first == [] && second == [] && third == [] { true } else { false }
        XCTAssertTrue(success, "three strikes are valid deliveries for the tenth frame")
        
        frame = Frame(number: 10)
        try frame.recordDelivery(leaving: [.ten])
        try frame.recordDelivery(leaving: [])
        try frame.recordDelivery(leaving: [.ten])
        success = if case let .three(first, second, third) = frame.deliveries, first == [.ten] && second == [] && third == [.ten] { true } else { false }
        XCTAssertTrue(success, "spare then nine count is a valid set of deliveries in the tenth frame")
        
        frame = Frame(number: 10)
        try frame.recordDelivery(leaving: [.ten])
        try frame.recordDelivery(leaving: [.ten])
        XCTAssertThrowsError(try frame.recordDelivery(leaving: []), "even in the tenth frame, a third delivery after an open frame is unsequenced") { error in
            XCTAssertEqual(error as! ScoresheetError, .unsequencedDelivery)
        }
    }
}
