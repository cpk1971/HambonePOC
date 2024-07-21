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
    @StateObject var game = BowlingGameViewModel()
    
    /*
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
     */

    var body: some Scene {
        WindowGroup {
            // ContentView()
            BowlingGameView(viewModel: game)
        }
        // .modelContainer(sharedModelContainer)
    }
}
