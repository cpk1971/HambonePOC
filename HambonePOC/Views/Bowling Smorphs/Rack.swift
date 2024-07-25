//
//  Rack.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-21.
//

import SwiftUI

fileprivate extension View {
    func pinFrame() -> some View {
        self.frame(width: 65, height: 65)
    }
    
    func pinPadding() -> some View {
        self.padding(.trailing, 8).padding(.bottom, 1)
    }
    
    func pinFont() -> some View {
        self.font(.custom("Helvetica Neue", size: 40).weight(.light))
    }
}

struct Rack: View {
    typealias Leave = BowlingScoresheet.Leave
    
    @Binding var pins: Leave
    var previousPins: Leave?
    
    @Environment(\.colorScheme) var colorScheme
        
    struct Pin: View {
        var number: Int
        @Binding var pins: Leave
        var previousPins: Leave?
        
        @Environment(\.colorScheme) var colorScheme
               
        var remainingPin: some View {
            ZStack {
                Circle()
                    .pinFrame()
                Text(number.formatted())
                    .pinFont()
                    .foregroundStyle(colorScheme.neutralReverseColor)
            }.onTapGesture {
                pins.remove(BowlingScoresheet.Pin.forNumber(number)!)
            }.pinPadding()
        }
        
        var felledPin: some View {
            ZStack {
                Circle()
                    .stroke(colorScheme.neutralColor, lineWidth: 4)
                    .pinFrame()
                Text(number.formatted())
                    .pinFont()
                    .foregroundColor(colorScheme.neutralColor)
            }.onTapGesture {
                pins.insert(BowlingScoresheet.Pin.forNumber(number)!)
            }.pinPadding()
        }
        
        // seems bad to copy-paste but we have to remove the action as well as
        // put in opacity; as well we only have three cases of this, and simplicity
        // outweighs reuse
        var shadowedPin: some View {
            ZStack {
                Circle()
                    .stroke(colorScheme.neutralColor, lineWidth: 4)
                    .pinFrame()
                Text(number.formatted())
                    .pinFont()
                    .foregroundColor(colorScheme.neutralColor)
            }
            .opacity(0.4)
            .pinPadding()
        }
        
        var body: some View {
            if let prev = previousPins, !prev.isPinNumberSet(number) {
                shadowedPin
            } else if pins.isPinNumberSet(number) {
                remainingPin
            } else {
                felledPin
            }
        }
    }
    
    func makePin(_ number: Int) -> Pin {
        Pin(number: number, pins: $pins, previousPins: previousPins)
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
