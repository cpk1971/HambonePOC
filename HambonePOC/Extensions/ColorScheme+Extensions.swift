//
//  ColorScheme+Extensions.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-22.
//

import SwiftUI

extension ColorScheme {
    var neutralColor: Color {
        self == .dark ? .white : .black
    }
    
    var neutralReverseColor: Color {
        self == .dark ? .black : .white
    }
}
