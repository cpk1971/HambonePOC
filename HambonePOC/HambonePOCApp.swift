//
//  HambonePOCApp.swift
//  HambonePOC
//
//  Created by Charles Kincy on 2024-07-05.
//

import SwiftUI
import SwiftData

@main
struct HambonePOCApp: App {
    // FIXME: need outer model
    @State var game = ScoringRoot()
    
    var body: some Scene {
        WindowGroup {
            GameEntry().environment(game)
        }
    }
}
