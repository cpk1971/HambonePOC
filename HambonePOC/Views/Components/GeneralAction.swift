//
//  GeneralAction.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-25.
//

import SwiftUI

struct GeneralAction: View {
    var label: String
    var action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    init (_ label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.custom("Helvetica", size: 20))
                .fontWeight(.bold)
                .foregroundColor(.green)
                .background(colorScheme.neutralReverseColor)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.green, lineWidth: 2)
                )
        }
    }
}

#Preview {
    GeneralAction("Say Hello!") {}
}
