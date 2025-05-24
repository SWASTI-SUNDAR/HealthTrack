import Foundation
import SwiftUI

struct HealthGoal: Identifiable, Codable {
    let id = UUID()
    var steps: Int
    var waterIntake: Double
    var sleepHours: Double
    var heartRate: Int
    var caloriesBurned: Int
    
    init(steps: Int = 10000, waterIntake: Double = 2.5, sleepHours: Double = 8.0, heartRate: Int = 70, caloriesBurned: Int = 2000) {
        self.steps = steps
        self.waterIntake = waterIntake
        self.sleepHours = sleepHours
        self.heartRate = heartRate
        self.caloriesBurned = caloriesBurned
    }
}

class GoalsManager: ObservableObject {
    @Published var currentGoals = HealthGoal()
    private let userDefaults = UserDefaults.standard
    private let goalsKey = "HealthGoals"
    
    init() {
        loadGoals()
    }
    
    func updateGoals(_ goals: HealthGoal) {
        currentGoals = goals
        saveGoals()
    }
    
    func getGoalProgress(for entry: HealthEntry) -> GoalProgress {
        return GoalProgress(
            stepsProgress: min(Double(entry.steps) / Double(currentGoals.steps), 1.0),
            waterProgress: min(entry.waterIntake / currentGoals.waterIntake, 1.0),
            sleepProgress: min(entry.sleepHours / currentGoals.sleepHours, 1.0),
            heartRateProgress: entry.heartRate > 0 ? (entry.heartRate <= currentGoals.heartRate ? 1.0 : 0.5) : 0.0,
            caloriesProgress: min(Double(entry.caloriesBurned) / Double(currentGoals.caloriesBurned), 1.0)
        )
    }
    
    private func saveGoals() {
        if let encoded = try? JSONEncoder().encode(currentGoals) {
            userDefaults.set(encoded, forKey: goalsKey)
        }
    }
    
    private func loadGoals() {
        if let data = userDefaults.data(forKey: goalsKey),
           let decoded = try? JSONDecoder().decode(HealthGoal.self, from: data) {
            currentGoals = decoded
        }
    }
}

struct GoalProgress {
    let stepsProgress: Double
    let waterProgress: Double
    let sleepProgress: Double
    let heartRateProgress: Double
    let caloriesProgress: Double
    
    var overallProgress: Double {
        (stepsProgress + waterProgress + sleepProgress + heartRateProgress + caloriesProgress) / 5.0
    }
}
