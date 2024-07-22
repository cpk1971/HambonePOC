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
            case .three(let first, let second, _):
                if first.contains(pin) {
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

#Preview {
    let frame = BowlingScoresheet.Frame(number: 1)
    return DeliverySummary(frame: frame)
}
