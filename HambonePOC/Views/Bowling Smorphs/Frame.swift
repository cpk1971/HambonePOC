//
//  Frame.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-22.
//

import SwiftUI

struct Frame: View {
    var frame: BowlingScoresheet.Frame
    var isInputFrame: Bool

    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            if isInputFrame {
                Rectangle()
                    .stroke(.red, lineWidth: 4)
                    .frame(width: 80, height: 160)
                    .zIndex(100)
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
                    FrameScoringLine(frame: frame)
                        .frame(width: 80, height: 40)
                }
                ZStack {
                    Rectangle()
                        .stroke(colorScheme.neutralColor, lineWidth: 1)
                        .frame(width: 80, height: 40)
                    .padding(0)
                    if(frame.isComplete) {
                        Text(frame.runningScore.formatted())
                            .id(frame.runningScore)
                            .font(.custom("Helvetica Neue", size: 24)).fontWeight(.bold)
                            .transition(.slideInFromRight)
                    }
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
    @State var inputFrame = 1
    
    func makeIt(frameNumber: Int, 
                with deliveries: BowlingScoresheet.Frame.Deliveries,
                scoring score: Int) -> some View {
        var frame = BowlingScoresheet.Frame(number: frameNumber)
        frame.deliveries = deliveries
        frame.runningScore = score
        
        return Frame(frame: frame, isInputFrame: frame.number == 1)
    }
       
    var body: some View {
        return HStack(spacing: 0) {
            makeIt(frameNumber: 1, with: .two(first: [.ten], second: []), scoring: 16)
            makeIt(frameNumber: 2, with: .one(leave: []), scoring: 36)
            makeIt(frameNumber: 3, with: .two(first: [.one, .two, .four, .ten], second: [.ten]), scoring: 45)
            makeIt(frameNumber: 10, with: .three(first: [], second: [], third: []), scoring: 255)
        }
    }
}
