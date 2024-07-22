//
//  Frame.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-22.
//

import SwiftUI

struct Frame: View {
    @Binding var inputFrame: Int
    var frame: BowlingScoresheet.Frame
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            if frame.number == inputFrame {
                Rectangle()
                    .stroke(.red, lineWidth: 4)
                    .frame(width: 80, height: 160)
            }
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    Rectangle()
                        .frame(width: 80, height: 20)
                        .opacity(0.5)
                    .padding(0)
                    Text(frame.number.formatted())
                        .foregroundStyle(colorScheme.neutralReverseColor)
                }
                ZStack {
                    Rectangle()
                        .stroke(colorScheme.neutralColor, lineWidth: 1)
                        .frame(width: 80, height: 40)
                    .padding(0)
                    Text(frame.line)
                }
                ZStack {
                    Rectangle()
                        .stroke(colorScheme.neutralColor, lineWidth: 1)
                        .frame(width: 80, height: 40)
                    .padding(0)
                    Text(frame.runningScore.formatted())
                        .font(.custom("Helvetica Neue", size: 24)).fontWeight(.bold)
                }
                ZStack {
                    Rectangle()
                        .stroke(colorScheme.neutralColor, lineWidth: 1)
                        .frame(width: 80, height: 60)
                    .padding(0)
                    DeliverySummary(frame: frame)
                }
            }.padding(0)
        }
    }
}

#Preview {
    PreviewWrapper()
}

fileprivate struct PreviewWrapper : View {
    @State var frame1: BowlingScoresheet.Frame
    @State var frame2: BowlingScoresheet.Frame
    @State var frame10: BowlingScoresheet.Frame
    @State var inputFrame = 1
    
    init() {
        var f1 = BowlingScoresheet.Frame(number: 1)
        f1.deliveries = .two(first: [.ten], second: [])
        f1.runningScore = 16
        
        var f2 = BowlingScoresheet.Frame(number: 2)
        f2.deliveries = .two(first: [.one, .two, .four, .ten], second: [.ten])
        f2.runningScore = 25

        var f10 = BowlingScoresheet.Frame(number: 10)
        f10.deliveries = .three(first: [], second: [], third: [])
        f10.runningScore = 290

        frame1 = f1
        frame2 = f2
        frame10 = f10
    }
    
    var body: some View {
        return HStack(spacing: 0) {
            Frame(inputFrame: $inputFrame, frame: frame1)
            Frame(inputFrame: $inputFrame, frame: frame2)
            Frame(inputFrame: $inputFrame, frame: frame10)
        }
    }
}
