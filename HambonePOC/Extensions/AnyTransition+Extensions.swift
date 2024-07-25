//
//  AnyTransition+Extensions.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-25.
//

import SwiftUI

extension AnyTransition {
    static var slideInFromRight: AnyTransition {
        let insertion = AnyTransition.move(edge: .trailing).combined(with: .opacity)
        let removal = AnyTransition.move(edge: .leading).combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }
    
    static var slideInFromTop: AnyTransition {
        let insertion = AnyTransition.move(edge: .top)
        let removal = AnyTransition.move(edge: .bottom)
        return .asymmetric(insertion: insertion, removal: removal)
    }
}
