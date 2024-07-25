//
//  FrameScoringLine.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-24.
//

import SwiftUI

fileprivate extension View {
    func fslFont() -> some View {
        self.font(.custom("Helvetica", size: 20)).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
    }
}

struct FrameScoringLine: View {
    var frame: BowlingScoresheet.Frame
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        switch frame.decomposedLine {
        case .normal(let first, let isSplit, let second):
            HStack {
                Spacer()
                ZStack {
                    if isSplit {
                        Circle()
                            .stroke(colorScheme.neutralColor, lineWidth: 2)
                            .frame(width: 20, height: 20)
                    }
                    Text(first).fslFont()
                }
                if !second.isEmpty {
                    Spacer().frame(width: 15)
                    Text(second).fslFont()
                }
                Spacer()
            }
        case .tenth(let first, let isFirstSplit, let second, let isSecondSplit, let third):
            HStack {
                Spacer()
                ZStack {
                    if isFirstSplit {
                        Circle()
                            .stroke(colorScheme.neutralColor, lineWidth: 2)
                            .frame(width: 20, height: 20)
                    }
                    Text(first).fslFont()
                }
                if !second.isEmpty {
                    Spacer().frame(width: third.isEmpty ? 15 : 10)
                    ZStack {
                        if isSecondSplit {
                            Circle()
                                .stroke(colorScheme.neutralColor, lineWidth: 2)
                                .frame(width: 20, height: 20)
                        }
                        Text(second).fslFont()
                    }
                }
                if !third.isEmpty {
                    Spacer().frame(width: 10)
                    Text(third).fslFont()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    VStack {
        FrameScoringLine(frame: BowlingScoresheet.Frame(number: 1, deliveries: .one(leave: [])))
        FrameScoringLine(frame: BowlingScoresheet.Frame(number: 1, deliveries: .two(first: [.seven, .ten], second: [.seven, .ten])))
        FrameScoringLine(frame: BowlingScoresheet.Frame(number: 1, deliveries: .two(first: [.ten], second: [])))
        FrameScoringLine(frame: BowlingScoresheet.Frame(number: 10, deliveries: .one(leave: [])))
        FrameScoringLine(frame: BowlingScoresheet.Frame(number: 10, deliveries: .two(first: [.seven, .ten], second: [.seven, .ten])))
        FrameScoringLine(frame: BowlingScoresheet.Frame(number: 10, deliveries: .three(first: [], second: [], third: [])))
        FrameScoringLine(frame: BowlingScoresheet.Frame(number: 10, deliveries: .three(first: [], second: [], third: [.ten])))
        FrameScoringLine(frame: BowlingScoresheet.Frame(number: 10, deliveries: .three(first: [], second: [], third: BowlingScoresheet.Leave.allCases)))
        FrameScoringLine(frame: BowlingScoresheet.Frame(number: 10, deliveries: .three(first: [.seven, .ten], second: [], third: [])))
        FrameScoringLine(frame: BowlingScoresheet.Frame(number: 10, deliveries: .three(first: [], second: [.seven, .ten], third: [])))

    }
}
