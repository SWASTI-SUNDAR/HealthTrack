//
//  HealthTrack2App.swift
//  HealthTrack2
//
//  Created by Swasti Sundar Pradhan on 24/05/25.
//

import SwiftUI

@main
struct HealthTrack2App: App {
    @StateObject private var healthDataStore = HealthDataStore()
    @StateObject private var goalsManager = GoalsManager()
    @StateObject private var achievementsManager = AchievementsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthDataStore)
                .environmentObject(goalsManager)
                .environmentObject(achievementsManager)
        }
    }
}
