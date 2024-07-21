//
//  Rack.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-21.
//

import SwiftUI

struct Rack: View {
    @State var pins: Set<BowlingScoresheet.Pins> = []
    
    @Environment(\.colorScheme) var colorScheme
    
    var strokeColor: Color {
        colorScheme == .light ? .black : .white
    }
    
    struct Constants {
        static let pinFont = Font.custom("Helvetica Neue", size: 40).weight(.light)
    }
    
    struct Pin: View {
        var number: Int
        @Binding var pins: Set<BowlingScoresheet.Pins>
        
        @Environment(\.colorScheme) var colorScheme
        
        var strokeColor: Color {
            colorScheme == .light ? .black : .white
        }
        
        var reverseColor: Color {
            colorScheme == .light ? .white : .black
        }
        
        var leftPin: some View {
            ZStack {
                Circle()
                    .frame(width: 65, height: 65)
                Text(number.formatted())
                    .font(Constants.pinFont)
                    .foregroundStyle(reverseColor)
            }.onTapGesture {
                pins.remove(BowlingScoresheet.Pins.forNumber(number)!)
            }
        }
        
        var felledPin: some View {
            ZStack {
                Circle()
                    .stroke(strokeColor, lineWidth: 4)
                    .frame(width: 65, height: 65)
                Text(number.formatted())
                    .font(Constants.pinFont)
                    .foregroundColor(strokeColor)
            }.onTapGesture {
                pins.insert(BowlingScoresheet.Pins.forNumber(number)!)
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
        }
        VStack {
            HStack {
                makePin(4)
                makePin(5)
                makePin(6)
            }
        }
        VStack {
            HStack {
                makePin(2)
                makePin(3)
            }
        }
        VStack {
            HStack {
                makePin(1)
            }
        }
    }
}

#Preview {
    Rack()
}
