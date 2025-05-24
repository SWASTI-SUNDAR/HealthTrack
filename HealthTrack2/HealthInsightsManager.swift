import Foundation
import SwiftUI

struct HealthInsight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let priority: InsightPriority
    let actionTitle: String?
    let value: String?
}

enum InsightPriority: Int, CaseIterable {
    case high = 3
    case medium = 2
    case low = 1
    
    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }
}

class HealthInsightsManager: ObservableObject {
    @Published var insights: [HealthInsight] = []
    
    func generateInsights(entries: [HealthEntry], goals: HealthGoal) {
        var newInsights: [HealthInsight] = []
        
        // Weekly analysis
        let weeklyEntries = getRecentEntries(entries, days: 7)
        let monthlyEntries = getRecentEntries(entries, days: 30)
        
        // Step insights
        newInsights.append(contentsOf: generateStepInsights(weeklyEntries: weeklyEntries, monthlyEntries: monthlyEntries, goals: goals))
        
        // Water insights
        newInsights.append(contentsOf: generateWaterInsights(weeklyEntries: weeklyEntries, goals: goals))
        
        // Sleep insights
        newInsights.append(contentsOf: generateSleepInsights(weeklyEntries: weeklyEntries, goals: goals))
        
        // Consistency insights
        newInsights.append(contentsOf: generateConsistencyInsights(entries: entries))
        
        // Mood insights
        newInsights.append(contentsOf: generateMoodInsights(weeklyEntries: weeklyEntries))
        
        // Weight insights
        newInsights.append(contentsOf: generateWeightInsights(monthlyEntries: monthlyEntries))
        
        // Sort by priority and update
        insights = newInsights.sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    private func getRecentEntries(_ entries: [HealthEntry], days: Int) -> [HealthEntry] {
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return entries.filter { $0.date >= cutoffDate }
    }
    
    private func generateStepInsights(weeklyEntries: [HealthEntry], monthlyEntries: [HealthEntry], goals: HealthGoal) -> [HealthInsight] {
        var insights: [HealthInsight] = []
        
        let weeklyAvg = weeklyEntries.isEmpty ? 0 : weeklyEntries.reduce(0) { $0 + $1.steps } / weeklyEntries.count
        let monthlyAvg = monthlyEntries.isEmpty ? 0 : monthlyEntries.reduce(0) { $0 + $1.steps } / monthlyEntries.count
        
        // Goal achievement analysis
        let goalAchievementRate = weeklyEntries.filter { $0.steps >= goals.steps }.count
        if goalAchievementRate < 3 {
            insights.append(HealthInsight(
                title: "Step Goal Challenge",
                description: "You've only achieved your step goal \(goalAchievementRate) times this week. Try taking short walks throughout the day.",
                icon: "figure.walk",
                color: .orange,
                priority: .medium,
                actionTitle: "Set Walk Reminders",
                value: "\(weeklyAvg) avg steps"
            ))
        }
        
        // Trend analysis
        if Double(weeklyAvg) > Double(monthlyAvg) * 1.1 {
            let percentageIncrease = Int(((Double(weeklyAvg) / Double(monthlyAvg)) - 1) * 100)
            insights.append(HealthInsight(
                title: "Great Step Progress!",
                description: "Your weekly average is \(percentageIncrease)% higher than your monthly average. Keep it up!",
                icon: "chart.line.uptrend.xyaxis",
                color: .green,
                priority: .low,
                actionTitle: nil,
                value: "+\(weeklyAvg - monthlyAvg) steps"
            ))
        }
        
        return insights
    }
    
    private func generateWaterInsights(weeklyEntries: [HealthEntry], goals: HealthGoal) -> [HealthInsight] {
        var insights: [HealthInsight] = []
        
        let avgWater = weeklyEntries.isEmpty ? 0.0 : weeklyEntries.reduce(0.0) { $0 + $1.waterIntake } / Double(weeklyEntries.count)
        
        if avgWater < goals.waterIntake * 0.8 {
            insights.append(HealthInsight(
                title: "Hydration Needs Attention",
                description: "Your average water intake is below your goal. Proper hydration improves energy and focus.",
                icon: "drop.fill",
                color: .blue,
                priority: .high,
                actionTitle: "Set Water Reminders",
                value: String(format: "%.1fL avg", avgWater)
            ))
        }
        
        return insights
    }
    
    private func generateSleepInsights(weeklyEntries: [HealthEntry], goals: HealthGoal) -> [HealthInsight] {
        var insights: [HealthInsight] = []
        
        let avgSleep = weeklyEntries.isEmpty ? 0.0 : weeklyEntries.reduce(0.0) { $0 + $1.sleepHours } / Double(weeklyEntries.count)
        
        if avgSleep < goals.sleepHours * 0.85 {
            insights.append(HealthInsight(
                title: "Sleep Quality Concern",
                description: "You're averaging less sleep than recommended. Quality sleep is crucial for recovery and health.",
                icon: "bed.double.fill",
                color: .purple,
                priority: .high,
                actionTitle: "Sleep Tips",
                value: String(format: "%.1fh avg", avgSleep)
            ))
        }
        
        return insights
    }
    
    private func generateConsistencyInsights(entries: [HealthEntry]) -> [HealthInsight] {
        var insights: [HealthInsight] = []
        
        let streak = getCurrentStreak(entries: entries)
        
        if streak >= 7 {
            insights.append(HealthInsight(
                title: "Amazing Consistency!",
                description: "You've logged entries for \(streak) consecutive days. Consistency is the key to lasting health improvements.",
                icon: "flame.fill",
                color: .orange,
                priority: .low,
                actionTitle: nil,
                value: "\(streak) days"
            ))
        } else if streak == 0 {
            insights.append(HealthInsight(
                title: "Get Back on Track",
                description: "Regular logging helps you stay aware of your health patterns. Start your streak today!",
                icon: "calendar",
                color: .red,
                priority: .medium,
                actionTitle: "Log Today",
                value: "0 day streak"
            ))
        }
        
        return insights
    }
    
    private func generateMoodInsights(weeklyEntries: [HealthEntry]) -> [HealthInsight] {
        var insights: [HealthInsight] = []
        
        let moodValues = weeklyEntries.map { entry -> Double in
            switch entry.mood {
            case .veryHappy: return 5.0
            case .happy: return 4.0
            case .neutral: return 3.0
            case .sad: return 2.0
            case .verySad: return 1.0
            }
        }
        
        if !moodValues.isEmpty {
            let avgMood = moodValues.reduce(0, +) / Double(moodValues.count)
            
            if avgMood < 3.0 {
                insights.append(HealthInsight(
                    title: "Mood Support Needed",
                    description: "Your mood has been lower than usual. Consider activities that boost your wellbeing.",
                    icon: "heart.fill",
                    color: .pink,
                    priority: .high,
                    actionTitle: "Wellness Tips",
                    value: String(format: "%.1f/5.0", avgMood)
                ))
            } else if avgMood >= 4.0 {
                insights.append(HealthInsight(
                    title: "Positive Mood Trend",
                    description: "Your mood has been consistently positive this week. Keep doing what makes you happy!",
                    icon: "face.smiling",
                    color: .yellow,
                    priority: .low,
                    actionTitle: nil,
                    value: String(format: "%.1f/5.0", avgMood)
                ))
            }
        }
        
        return insights
    }
    
    private func generateWeightInsights(monthlyEntries: [HealthEntry]) -> [HealthInsight] {
        var insights: [HealthInsight] = []
        
        let weightEntries = monthlyEntries.filter { $0.weight > 0 }.sorted { $0.date < $1.date }
        
        if weightEntries.count >= 2 {
            let firstWeight = weightEntries.first!.weight
            let lastWeight = weightEntries.last!.weight
            let weightChange = lastWeight - firstWeight
            
            if abs(weightChange) > 2.0 {
                let direction = weightChange > 0 ? "gained" : "lost"
                let color: Color = abs(weightChange) > 5.0 ? .orange : .blue
                
                insights.append(HealthInsight(
                    title: "Weight Change Detected",
                    description: "You've \(direction) \(String(format: "%.1f", abs(weightChange)))kg this month. Monitor your trends.",
                    icon: "scalemass.fill",
                    color: color,
                    priority: .medium,
                    actionTitle: "View Trends",
                    value: String(format: "%+.1fkg", weightChange)
                ))
            }
        }
        
        return insights
    }
    
    private func getCurrentStreak(entries: [HealthEntry]) -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        for _ in 0..<30 {
            if entries.contains(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                streak += 1
            } else {
                break
            }
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        return streak
    }
}
