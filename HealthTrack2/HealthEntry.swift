import Foundation

struct HealthEntry: Identifiable, Codable {
    let id = UUID()
    let date: Date
    var steps: Int
    var waterIntake: Double // in liters
    var sleepHours: Double
    
    init(date: Date = Date(), steps: Int = 0, waterIntake: Double = 0.0, sleepHours: Double = 0.0) {
        self.date = date
        self.steps = steps
        self.waterIntake = waterIntake
        self.sleepHours = sleepHours
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
