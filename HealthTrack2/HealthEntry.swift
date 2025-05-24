import Foundation
import SwiftUI

struct HealthEntry: Identifiable, Codable {
    let id = UUID()
    let date: Date
    var steps: Int
    var waterIntake: Double // in liters
    var sleepHours: Double
    var heartRate: Int // beats per minute
    var caloriesBurned: Int
    var mood: MoodLevel
    var weight: Double // in kg
    
    init(date: Date = Date(), steps: Int = 0, waterIntake: Double = 0.0, sleepHours: Double = 0.0, heartRate: Int = 0, caloriesBurned: Int = 0, mood: MoodLevel = .neutral, weight: Double = 0.0) {
        self.date = date
        self.steps = steps
        self.waterIntake = waterIntake
        self.sleepHours = sleepHours
        self.heartRate = heartRate
        self.caloriesBurned = caloriesBurned
        self.mood = mood
        self.weight = weight
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

enum MoodLevel: String, CaseIterable, Codable {
    case veryHappy = "Very Happy"
    case happy = "Happy"
    case neutral = "Neutral"
    case sad = "Sad"
    case verySad = "Very Sad"
    
    var emoji: String {
        switch self {
        case .veryHappy: return "😄"
        case .happy: return "😊"
        case .neutral: return "😐"
        case .sad: return "😢"
        case .verySad: return "😭"
        }
    }
    
    var color: Color {
        switch self {
        case .veryHappy: return .green
        case .happy: return .mint
        case .neutral: return .gray
        case .sad: return .orange
        case .verySad: return .red
        }
    }
}
