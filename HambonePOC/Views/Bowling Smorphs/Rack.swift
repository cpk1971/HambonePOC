//
//  Rack.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-21.
//

import SwiftUI

struct Rack: View {
    @Binding var pins: Set<BowlingScoresheet.Pin>
    
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        static let pinFont = Font.custom("Helvetica Neue", size: 40).weight(.light)
    }
    
    struct Pin: View {
        var number: Int
        @Binding var pins: Set<BowlingScoresheet.Pin>
        
        @Environment(\.colorScheme) var colorScheme
               
        var leftPin: some View {
            ZStack {
                Circle()
                    .frame(width: 65, height: 65)
                Text(number.formatted())
                    .font(Constants.pinFont)
                    .foregroundStyle(colorScheme.neutralReverseColor)
            }.onTapGesture {
                pins.remove(BowlingScoresheet.Pin.forNumber(number)!)
            }
        }
        
        var felledPin: some View {
            ZStack {
                Circle()
                    .stroke(colorScheme.neutralColor, lineWidth: 4)
                    .frame(width: 65, height: 65)
                Text(number.formatted())
                    .font(Constants.pinFont)
                    .foregroundColor(colorScheme.neutralColor)
            }.onTapGesture {
                pins.insert(BowlingScoresheet.Pin.forNumber(number)!)
            }
        }
        
        var body: some View {
            if pins.isPinNumberSet(number) {
                leftPin.padding(.trailing, 8).padding(.bottom, 1)
            } else {
                felledPin.padding(.trailing, 8).padding(.bottom, 1)
            }
        }
    }
    
    func makePin(_ number: Int) -> Pin {
        Pin(number: number, pins: $pins)
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

fileprivate struct PreviewWrapper : View {
    @State var pins: Set<BowlingScoresheet.Pin> = []
    
    var body: some View {
        Rack(pins: $pins)
    }
}

#Preview {
    PreviewWrapper()
}
