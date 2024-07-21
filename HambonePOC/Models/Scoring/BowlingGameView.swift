//
//  BowlingGameView.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-09.
//

import SwiftUI

struct BowlingGameView: View {
    @ObservedObject var viewModel: BowlingGameViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    BowlingGameView(viewModel: BowlingGameViewModel())
}
