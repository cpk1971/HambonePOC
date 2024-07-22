//
//  MiniRack.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-22.
//

import SwiftUI

struct DeliverySummary: View {
    var frame: BowlingScoresheet.Frame
    
    enum PinState {
        case felledFirst
        case felledSecond
        case up
    }
    
    struct Pin: View {
        var number: Int
        var deliveries: BowlingScoresheet.Frame.Deliveries
        
        @Environment(\.colorScheme) var colorScheme
        
        func state() -> PinState {
            let pin = BowlingScoresheet.Pin.forNumber(number)!
            
            return switch deliveries {
            case .none:
                    .felledSecond
            case .one(let leave):
                leave.contains(pin) ? .felledSecond : .felledFirst
            case .two(let first, let second):
                if first.contains(pin) {
                    if second.contains(pin) {
                        .up
                    } else {
                        .felledSecond
                    }
                } else {
                    .felledFirst
                }
                // only showing first rack for now
            case .three(let first, let second, let third):
                if first == [] {
                    if second.contains(pin) {
                        if third.contains(pin) {
                            .up
                        } else {
                            .felledSecond
                        }
                    } else {
                        .felledFirst
                    }
                } else if first.contains(pin) {
                    if second.contains(pin) {
                        .up
                    } else {
                        .felledSecond
                    }
                } else {
                    .felledFirst
                }
            }
        }
        
        var body: some View {
            switch state() {
            case .felledFirst:
                Circle()
                    .stroke(colorScheme.neutralColor, lineWidth: 1)
                    .opacity(0.5)
                    .frame(width: 5, height: 5)
            case .felledSecond:
                Circle()
                    .frame(width: 5, height: 5)
            case .up:
                Circle()
                    .stroke(.red, lineWidth: 1)
                    .frame(width: 5, height: 5)
            }
        }
    }
    
    func makePin(_ number: Int) -> some View {
        Pin(number: number, deliveries: frame.deliveries)
    }
    
    var body: some View {
        if (frame.isStrike && frame.number < 10) || frame.isDouble || frame.isTriple {
            if frame.number < 10 {
                Text("❌").font(.title)
            } else {
                if frame.isDouble {
                    Text("❌❌").font(.title2)
                } else {
                    Text("❌❌❌").font(.caption)
                }
            }
        } else {
            VStack {
                HStack {
                    makePin(7)
                    makePin(8)
                    makePin(9)
                    makePin(10)
                }
                HStack {
                    makePin(4)
                    makePin(5)
                    makePin(6)
                }
                HStack {
                    makePin(2)
                    makePin(3)
                }
                HStack {
                    makePin(1)
                }
            }
        }
    }
}

fileprivate func makeIt(frameNumber: Int, with deliveries: BowlingScoresheet.Frame.Deliveries) -> some View {
    var frame = BowlingScoresheet.Frame(number: frameNumber)
    frame.deliveries = deliveries
    
    return VStack {
        Text(frame.line)
        DeliverySummary(frame: frame).frame(width: 80, height: 60)
    }
    
}

#Preview {
    VStack {
        HStack {
            makeIt(frameNumber: 1, with: .one(leave: []))
            makeIt(frameNumber: 1, with: .two(first: [.ten], second: []))
            makeIt(frameNumber: 1, with: .two(first: [.one, .two, .four, .ten], second: [.ten]))
        }.padding(.bottom, 20)
        HStack {
            makeIt(frameNumber: 10, with: .three(first: [], second: [.six, .ten], third: []))
            makeIt(frameNumber: 10, with: .three(first: [.four, .seven], second: [], third: []))
            makeIt(frameNumber: 10, with: .three(first: [.four, .seven], second: [], third: [.ten]))
        }
        HStack {
            makeIt(frameNumber: 10, with: .three(first: [], second: [.six, .ten], third: [.ten]))
            makeIt(frameNumber: 10, with: .three(first: [], second: [], third: [.ten]))
            makeIt(frameNumber: 10, with: .three(first: [], second: [], third: []))
        }
    }
}
