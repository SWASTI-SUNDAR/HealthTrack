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
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var healthInsightsManager = HealthInsightsManager()
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "HasCompletedOnboarding")
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthDataStore)
                .environmentObject(goalsManager)
                .environmentObject(achievementsManager)
                .environmentObject(themeManager)
                .environmentObject(healthInsightsManager)
                .preferredColorScheme(themeManager.currentTheme == .dark ? .dark : themeManager.currentTheme == .light ? .light : nil)
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView(isPresented: $showOnboarding)
                }
                .onAppear {
                    // Generate insights when app loads
                    healthInsightsManager.generateInsights(
                        entries: healthDataStore.entries,
                        goals: goalsManager.currentGoals
                    )
                }
                .onChange(of: healthDataStore.entries) { _ in
                    // Update insights when entries change
                    healthInsightsManager.generateInsights(
                        entries: healthDataStore.entries,
                        goals: goalsManager.currentGoals
                    )
                }
        }
    }
}
