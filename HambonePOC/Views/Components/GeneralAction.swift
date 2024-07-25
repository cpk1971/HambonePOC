//
//  GeneralAction.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-25.
//

import SwiftUI

fileprivate struct AnimatedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.75 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}

struct GeneralAction: View {
    var label: String
    var action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    init (_ label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
    
    var body: some View {
        Button(action: { withAnimation { action() }}) {
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
        .buttonStyle(AnimatedButtonStyle())
        
    }
}

#Preview {
    GeneralAction("Say Hello!") {}
}
