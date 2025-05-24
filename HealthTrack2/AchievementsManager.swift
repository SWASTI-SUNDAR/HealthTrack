import Foundation
import SwiftUI

struct Achievement: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: String
    let requirement: AchievementRequirement
    var isUnlocked: Bool = false
    var dateUnlocked: Date?
    
    var colorValue: Color {
        switch color {
        case "gold": return .yellow
        case "silver": return .gray
        case "bronze": return .brown
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        default: return .blue
        }
    }
}

enum AchievementRequirement: Codable {
    case steps(Int)
    case water(Double)
    case sleep(Double)
    case consecutiveDays(Int)
    case heartRate(Int)
    case calories(Int)
    case perfectDay
}

class AchievementsManager: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var recentlyUnlocked: [Achievement] = []
    private let userDefaults = UserDefaults.standard
    private let achievementsKey = "Achievements"
    
    init() {
        setupDefaultAchievements()
        loadAchievements()
    }
    
    func checkAchievements(entries: [HealthEntry], goals: HealthGoal) {
        var newlyUnlocked: [Achievement] = []
        
        for i in achievements.indices {
            if !achievements[i].isUnlocked {
                if isAchievementMet(achievements[i], entries: entries, goals: goals) {
                    achievements[i].isUnlocked = true
                    achievements[i].dateUnlocked = Date()
                    newlyUnlocked.append(achievements[i])
                }
            }
        }
        
        if !newlyUnlocked.isEmpty {
            recentlyUnlocked.append(contentsOf: newlyUnlocked)
            saveAchievements()
        }
    }
    
    private func isAchievementMet(_ achievement: Achievement, entries: [HealthEntry], goals: HealthGoal) -> Bool {
        guard let todaysEntry = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: Date()) }) else {
            return false
        }
        
        switch achievement.requirement {
        case .steps(let target):
            return todaysEntry.steps >= target
        case .water(let target):
            return todaysEntry.waterIntake >= target
        case .sleep(let target):
            return todaysEntry.sleepHours >= target
        case .heartRate(let target):
            return todaysEntry.heartRate <= target && todaysEntry.heartRate > 0
        case .calories(let target):
            return todaysEntry.caloriesBurned >= target
        case .perfectDay:
            return todaysEntry.steps >= goals.steps &&
                   todaysEntry.waterIntake >= goals.waterIntake &&
                   todaysEntry.sleepHours >= goals.sleepHours
        case .consecutiveDays(let target):
            return getConsecutiveDays(entries: entries) >= target
        }
    }
    
    private func getConsecutiveDays(entries: [HealthEntry]) -> Int {
        let calendar = Calendar.current
        var consecutive = 0
        var currentDate = Date()
        
        for _ in 0..<30 { // Check last 30 days
            if entries.contains(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                consecutive += 1
            } else {
                break
            }
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        return consecutive
    }
    
    private func setupDefaultAchievements() {
        achievements = [
            Achievement(title: "First Steps", description: "Log your first health entry", icon: "star.fill", color: "bronze", requirement: .steps(1)),
            Achievement(title: "Step Master", description: "Walk 10,000 steps in a day", icon: "figure.walk", color: "gold", requirement: .steps(10000)),
            Achievement(title: "Hydration Hero", description: "Drink 3L of water in a day", icon: "drop.fill", color: "blue", requirement: .water(3.0)),
            Achievement(title: "Sleep Champion", description: "Get 8+ hours of sleep", icon: "bed.double.fill", color: "purple", requirement: .sleep(8.0)),
            Achievement(title: "Perfect Day", description: "Meet all your daily goals", icon: "checkmark.circle.fill", color: "gold", requirement: .perfectDay),
            Achievement(title: "Consistency King", description: "Log entries for 7 consecutive days", icon: "calendar", color: "green", requirement: .consecutiveDays(7)),
            Achievement(title: "Calorie Crusher", description: "Burn 2500+ calories in a day", icon: "flame.fill", color: "gold", requirement: .calories(2500))
        ]
    }
    
    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            userDefaults.set(encoded, forKey: achievementsKey)
        }
    }
    
    private func loadAchievements() {
        if let data = userDefaults.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            // Merge with default achievements to handle new ones
            for defaultAchievement in achievements {
                if !decoded.contains(where: { $0.title == defaultAchievement.title }) {
                    achievements.append(defaultAchievement)
                }
            }
            // Update existing achievements
            for i in achievements.indices {
                if let saved = decoded.first(where: { $0.title == achievements[i].title }) {
                    achievements[i] = saved
                }
            }
        }
    }
}
