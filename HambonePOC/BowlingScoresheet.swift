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

typealias Leave = Set<Pins>

enum Status {
    case notThrown
    case firstBallThrown(leave: Leave)
    case secondBallThrown(first: Leave, second: Leave)
    case thirdBallThrown(first: Leave, second: Leave, third: Leave)
}

enum ScoresheetError : Error {
    case unsequencedThrow
}

struct Frame : CustomStringConvertible {
    var number: Int
    var status: Status = .notThrown
    var runningScore: Int = 0
    
    var isComplete: Bool {
        switch status {
        case .notThrown: 
            false
        case .firstBallThrown(let leave):
            leave == [] && number < 10
        case .secondBallThrown(_, let second): 
            second != [] || number < 10
        case .thirdBallThrown:
            true
        }
    }
    
    var firstBallCount: Int {
        switch status {
        case .notThrown:
            0
        case let .firstBallThrown(first):
            10 - first.count
        case let .secondBallThrown(first, _):
            10 - first.count
        case let .thirdBallThrown(first, _, _):
            10 - first.count
        }
    }
    
    // this is a special case because of the tenth frame
    var secondBallCount: Int {
        switch status {
        case .notThrown:
            0
        case .firstBallThrown:
            0
        case let .secondBallThrown(first, second):
            if number == 10 && isStrike {
                10 - second.count
            } else {
                first.count - second.count
            }
        case let .thirdBallThrown(first, second, _):
            if number == 10 && isStrike {
                10 - second.count
            } else {
                first.count - second.count
            }
        }
    }
    
    var totalCount: Int {
        switch status {
        case .notThrown:
            0
        case let .firstBallThrown(leave):
            10 - leave.count
        case let .secondBallThrown(_, second):
            10 - second.count
        case let .thirdBallThrown(first, second, third):
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
        switch status {
        case .notThrown: 
            false
        case let .firstBallThrown(leave): 
            leave.count == 0
        case let .secondBallThrown(first, _): 
            first.count == 0
        case let .thirdBallThrown(first, _, _): 
            first.count == 0
        }
    }
    
    var isSpare: Bool {
        switch status {
        case .notThrown:
            false
        case .firstBallThrown:
            false
        case let .secondBallThrown(_, second):
            second.count == 0
        case let .thirdBallThrown(_, second, _):
            second.count == 0
        }
    }
    
    var description: String {
        "[#\(number): \(line) = \(runningScore)]"
    }
    
    var line: String {
        return switch status {
        case .notThrown:
            ""
        case .firstBallThrown:
            isStrike ? "X" : "\(firstBallCount)"
        case .secondBallThrown:
            isSpare ? "\(firstBallCount) /" : "\(firstBallCount) \(secondBallCount)"
        case let .thirdBallThrown(_, second, third):
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
    
    mutating func recordThrow(leaving leave: Leave) throws {
        if isComplete {
            throw ScoresheetError.unsequencedThrow
        }
        
        switch status {
        case .notThrown:
            status = .firstBallThrown(leave: leave)
        case let .firstBallThrown(first):
            status = .secondBallThrown(first: first, second: leave)
        case let .secondBallThrown(first, second):
            if number == 10 {
                status = .thirdBallThrown(first: first, second: second, third: leave)
            } else {
                throw ScoresheetError.unsequencedThrow
            }
        case .thirdBallThrown:
            throw ScoresheetError.unsequencedThrow
        }
    }
}


struct BowlingScoresheet {
    private(set) var frames: [Frame]
    private(set) var totalScore = 0
    
    init() {
        frames = (1...10).map { frameNumber in
            Frame(number: frameNumber, status: .notThrown, runningScore: 0)
        }
    }
    
    mutating func updateRunningScore() {
        var total = 0
        
        for i in frames.indices {
            var frame = frames[i]
            
            let currentScore = if(frame.number < 9) {
                if frame.isStrike {
                    if frames[i+1].isStrike {
                        if frames[i+2].isStrike {
                            30
                        } else {
                            20 + frames[i+2].totalCount
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
            frame.runningScore = total
        }
    }
}


