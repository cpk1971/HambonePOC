//
//  AnyTransition+Extensions.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-25.
//

import SwiftUI

extension AnyTransition {
    static var slideInFromRight: AnyTransition {
        let insertion = AnyTransition.move(edge: .trailing)
        let removal = AnyTransition.move(edge: .leading)
        return .asymmetric(insertion: insertion, removal: removal)
    }
}
