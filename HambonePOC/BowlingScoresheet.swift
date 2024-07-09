//
//  BowlingScoresheet.swift
//  HambonePOC
//
//  This is a model of a scoresheet for a game of bowling, scored
//  as American Tenpins, which is the scoring mechanism specified
//  by the US Bowling Congress Playing Rules, Rule 2.
//
//  Created by Charles Kincy on 2024-07-05.
//

import Foundation

/// A model of a scoresheet used in American Tenpins, the form
/// of bowling that most Americans just call "bowling".
///
/// Note that we'll probably have to do some tremendous refactoring to
/// support the following:
/// 1. Nine-pin "no tap".
/// 2. World Tenpins, a variant (and significantly less complex) form of scoring.
///
class BowlingScoresheet: CustomStringConvertible, ObservableObject {
    /// A model of bowling pins.
    ///
    /// In fact we could just represent each pin with a bit, but to make
    /// our code easier to read, we'll refer to them as an enumeration.
    /// Assigning values may make it easier to compactly represent a game when
    /// we get around to storage.
    // TODO: there isn't a way to represent a foul here; perhaps another bit?
    enum Pins: Int {
        case one   = 0x001,
             two   = 0x002,
             three = 0x004,
             four  = 0x008,
             five  = 0x010,
             six   = 0x020,
             seven = 0x040,
             eight = 0x080,
             nine  = 0x100,
             ten   = 0x200
    }

    /// A "leave" is what is left *after* a bowler throws a ball at a setup.
    /// This allows us to keep track of what pins were left, because one of the
    /// features of Hambone will be to track a bowler's performance in converting spares.
    /// Remembering what pins were left as part of the scoresheet is essential to this feature.
    typealias Leave = Set<Pins>

    /// Errors thrown by the API
    enum Error : Swift.Error {
        case gameCompleted
        case invalidFrame
        case unsequencedDelivery
    }

    /// A model of a frame of bowling.
    /// This contains some state which has to be processed externally, such as the running score.
    struct Frame : CustomStringConvertible {
        /// How much of a frame a bowler has delivered.  Whether the frame is complete or not is
        /// contextual based upon the frame's number and whether or not the bowler has bowled a strike.
        enum Deliveries {
            case none
            case one(leave: Leave)
            case two(first: Leave, second: Leave)
            case three(first: Leave, second: Leave, third: Leave)
        }
        
        var number: Int
        var deliveries: Deliveries = .none
        var runningScore: Int = 0
        
        // implementation is in extension towards end of file
    }
   
    private(set) var frames: [Frame]
    private(set) var totalScore = 0
    private(set) var currentNumber: Int? = 1
    
    init() {
        frames = (1...10).map { frameNumber in
            Frame(number: frameNumber, deliveries: .none, runningScore: 0)
        }
    }
    
    var currentFrame: Frame? {
        if let currentNumber {
            frames[currentNumber - 1]
        } else {
            nil
        }
    }
    
    var isComplete: Bool {
        // this might not be the best?
        currentNumber == .none
    }
    
    var description: String {
        var result = "["
        frames.forEach { result += $0.description }
        result += "]"
        return result
    }
    
    func updateRunningScore() {
        var total = 0
        
        for i in frames.indices {
            let frame = frames[i]
            
            let currentScore = if(frame.number < 9) {
                if frame.isStrike {
                    if frames[i+1].isStrike {
                        if frames[i+2].isStrike {
                            30
                        } else {
                            20 + frames[i+2].firstBallCount
                        }
                    } else {
                        10 + frames[i+1].totalCount
                    }
                } else if frame.isSpare {
                    10 + frames[i+1].firstBallCount
                } else {
                    frame.totalCount
                }
            } else if frame.number == 9 {
                if frame.isStrike {
                    10 + frames[i+1].firstBallCount + frames[i+1].secondBallCount
                } else if frame.isSpare {
                    10 + frames[i+1].firstBallCount
                } else {
                    frame.totalCount
                }
            } else {
                // frame 10
                frame.totalCount
            }
            
            total += currentScore
            frames[i].runningScore = total
        }
        
        totalScore = total
    }
    
    func recordDelivery(leaving leave: Leave) throws {
        if isComplete {
            throw Error.gameCompleted
        }
        
        let index = currentNumber! - 1
        
        try frames[index].recordDelivery(leaving: leave)
        if frames[index].isComplete {
            if currentNumber! < 10 {
                currentNumber! += 1
            } else {
                currentNumber = nil
            }
        }
    }
    
    func resetFrame(number: Int?) throws -> (first: Leave?, second: Leave?, third: Leave?)  {
        if number == nil && currentNumber == nil {
            throw Error.gameCompleted
        }

        let number = number ?? currentNumber!

        guard (1...10).contains(number) else {
            throw Error.invalidFrame
        }
        
        currentNumber = number
        return frames[number - 1].reset()
    }
    
    func resetGame(toFrame number: Int = 1) throws {
        guard (1...10).contains(number) else {
            throw Error.invalidFrame
        }
        
        for i in (number-1)...9 {
            (_, _, _) = frames[i].reset()
        }
    }
}

extension BowlingScoresheet.Leave {
    /// The leave is a split if it meets the criteria specified by USBC Playing Rule 2h, which is:
    ///
    /// A split is a setup of pins left standing after the first delivery, provided the head pin is down and at least one pin is down:
    ///
    ///    1. Between two or more standing pins; e.g., 7-9 or 3-10.
    ///    2. Immediately ahead of two or more standing pins; e.g., 5-6.
    var isSplit: Bool {
        // ...it must have at least two standing pins
        if count <= 1 {
            false
        // ...the headpin must be down
        } else if contains(.one) {
            false
        // ...if two pins are adjacent but the pin in front is down, it's a split, irrespective of the rest
        } else if contains(.two) && contains(.three) ||
                  contains(.four) && contains(.five) && !contains(.two) ||
                  contains(.five) && contains(.six) && !contains(.three) ||
                  contains(.seven) && contains(.eight) && !contains(.four) ||
                  contains(.eight) && contains(.nine) && !contains(.five) ||
                  contains(.nine) && contains(.ten) && !contains(.six) {
            true
        // and now a heuristic:  any single pin "out by itself" makes the whole thing a split
        } else if contains(.two) && !(contains(.four) || contains(.five) || contains(.eight)) ||
                  contains(.three) && !(contains(.five) || contains(.six) || contains(.nine)) ||
                  contains(.four) && !(contains(.two) || contains(.seven) || contains(.eight)) ||
                  contains(.five) && !(contains(.two) || contains(.three) || contains(.eight) || contains(.nine)) ||
                  contains(.six) && !(contains(.three) || contains(.nine) || contains(.ten)) ||
                  contains(.seven) && !(contains(.four) || contains(.eight)) ||
                  contains(.eight) && !(contains(.two) || contains(.four) || contains(.five)) ||
                  contains(.nine) && !(contains(.three) || contains(.five) || contains(.six)) ||
                  contains(.ten) && !(contains(.six) || contains(.nine)) {
            true
        // finally, complex edge cases that cover the "big 4" and the "Greek Church" and the "4 through the middle"
        } else if (contains(.four) && contains(.six)) && !contains(.five) ||
                  (contains(.seven) && contains(.nine)) && !contains(.eight) ||
                  (contains(.eight) && contains(.ten)) && !contains(.nine) {
            true
        // and we're out of criteria--it's therefore not a split
        } else {
            false
        }
    }
    
}

extension BowlingScoresheet.Frame {
    typealias Leave = BowlingScoresheet.Leave
    typealias Error = BowlingScoresheet.Error
    
    var isComplete: Bool {
        switch deliveries {
        case .none:
            false
        case let .one(leave):
            leave == [] && number < 10
        case let .two(first, second):
            if number < 10 {
                true
            } else {
                first != [] && second != []
            }
        case .three:
            true
        }
    }
    
    var firstBallCount: Int {
        switch deliveries {
        case .none:
            0
        case let .one(first):
            10 - first.count
        case let .two(first, _):
            10 - first.count
        case let .three(first, _, _):
            10 - first.count
        }
    }
    
    // this is a special case because of the tenth frame
    var secondBallCount: Int {
        switch deliveries {
        case .none:
            0
        case .one:
            0
        case let .two(first, second):
            if number == 10 && isStrike {
                10 - second.count
            } else {
                first.count - second.count
            }
        case let .three(first, second, _):
            if number == 10 && isStrike {
                10 - second.count
            } else {
                first.count - second.count
            }
        }
    }
    
    var totalCount: Int {
        switch deliveries {
        case .none:
            0
        case let .one(leave):
            10 - leave.count
        case let .two(_, second):
            10 - second.count
        case let .three(first, second, third):
            if first.count == 0 {
                if second.count == 0 {
                    30 - third.count
                } else {
                    20 - third.count
                }
            } else {
                20 - third.count
            }
        }
    }
    
    var isStrike: Bool {
        switch deliveries {
        case .none:
            false
        case let .one(leave):
            leave.count == 0
        case let .two(first, _):
            first.count == 0
        case let .three(first, _, _):
            first.count == 0
        }
    }
    
    var isSpare: Bool {
        switch deliveries {
        case .none:
            false
        case .one:
            false
        case let .two(_, second):
            second.count == 0
        case let .three(_, second, _):
            second.count == 0
        }
    }
    
    var description: String {
        "[#\(number): \(line) = \(runningScore)]"
    }
    
    var line: String {
        return switch deliveries {
        case .none:
            ""
        case .one:
            isStrike ? "X" : "\(firstBallCount)"
        case .two:
            if !isStrike || (number < 10) {
                isSpare ? "\(firstBallCount) /" : "\(firstBallCount) \(secondBallCount)"
            } else {
                "X \(secondBallCount)"
            }
        case let .three(_, second, third):
            if isStrike {
                if second.count == 0 && third.count == 0 {
                    "X X X"
                } else if second.count == 0 {
                    "X X \(10 - third.count)"
                } else if third.count == 0 {
                    "X \(10 - second.count) /"
                } else {
                    "X \(10 - second.count) \(second.count - third.count)"
                }
            } else if isSpare {
                if third.count == 0 {
                    "\(firstBallCount) / X"
                } else {
                    "\(firstBallCount) / \(10 - third.count)"
                }
            } else {
                "\(firstBallCount) \(secondBallCount)"
            }
        }
    }
    
    mutating func recordDelivery(leaving leave: Leave) throws {
        if isComplete {
            throw Error.unsequencedDelivery
        }
        
        switch deliveries {
        case .none:
            deliveries = .one(leave: leave)
        case let .one(first):
            deliveries = .two(first: first, second: leave)
        case let .two(first, second):
            if number == 10 {
                deliveries = .three(first: first, second: second, third: leave)
            } else {
                throw Error.unsequencedDelivery
            }
        case .three:
            throw Error.unsequencedDelivery
        }
    }
    
    mutating func reset() -> (first: Leave?, second: Leave?, third: Leave?) {
        let oldStatus = deliveries
        deliveries = .none
        return switch oldStatus {
        case .none:
            (nil, nil, nil)
        case let .one(first):
            (first, nil, nil)
        case let .two(first, second):
            (first, second, nil)
        case let .three(first, second, third):
            (first, second, third)
        }
    }

}
