import SwiftUI
import Charts

struct SummaryView: View {
    @EnvironmentObject var dataStore: HealthDataStore
    @State private var selectedMetric: HealthMetric = .steps
    
    enum HealthMetric: String, CaseIterable {
        case steps = "Steps"
        case water = "Water (L)"
        case sleep = "Sleep (hrs)"
        
        var icon: String {
            switch self {
            case .steps: return "figure.walk"
            case .water: return "drop.fill"
            case .sleep: return "bed.double.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .steps: return .green
            case .water: return .blue
            case .sleep: return .purple
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Weekly Summary")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Your health progress this week")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Metric Selector
                    Picker("Health Metric", selection: $selectedMetric) {
                        ForEach(HealthMetric.allCases, id: \.self) { metric in
                            HStack {
                                Image(systemName: metric.icon)
                                Text(metric.rawValue)
                            }
                            .tag(metric)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 20)
                    
                    // Chart
                    if #available(iOS 16.0, *) {
                        ChartView(metric: selectedMetric, entries: dataStore.getWeeklyEntries())
                            .frame(height: 200)
                            .padding(.horizontal, 20)
                    } else {
                        SimpleChartView(metric: selectedMetric, entries: dataStore.getWeeklyEntries())
                            .frame(height: 200)
                            .padding(.horizontal, 20)
                    }
                    
                    // Weekly Stats
                    WeeklyStatsView(entries: dataStore.getWeeklyEntries())
                        .padding(.horizontal, 20)
                    
                    // Entries List
                    EntriesListView(entries: dataStore.getWeeklyEntries())
                        .padding(.horizontal, 20)
                    
                    Spacer(minLength: 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

@available(iOS 16.0, *)
struct ChartView: View {
    let metric: SummaryView.HealthMetric
    let entries: [HealthEntry]
    
    var chartData: [(String, Double)] {
        entries.map { entry in
            let value: Double
            switch metric {
            case .steps:
                value = Double(entry.steps)
            case .water:
                value = entry.waterIntake
            case .sleep:
                value = entry.sleepHours
            }
            return (entry.dayOfWeek, value)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(metric.rawValue) This Week")
                .font(.headline)
                .fontWeight(.semibold)
            
            Chart {
                ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                    BarMark(
                        x: .value("Day", data.0),
                        y: .value(metric.rawValue, data.1)
                    )
                    .foregroundStyle(metric.color.gradient)
                    .cornerRadius(4)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct SimpleChartView: View {
    let metric: SummaryView.HealthMetric
    let entries: [HealthEntry]
    
    var chartData: [(String, Double)] {
        entries.map { entry in
            let value: Double
            switch metric {
            case .steps:
                value = Double(entry.steps)
            case .water:
                value = entry.waterIntake
            case .sleep:
                value = entry.sleepHours
            }
            return (entry.dayOfWeek, value)
        }
    }
    
    var maxValue: Double {
        chartData.map(\.1).max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(metric.rawValue) This Week")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(metric.color.gradient)
                            .frame(width: 32, height: CGFloat(data.1 / maxValue * 120))
                        
                        Text(data.0)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct WeeklyStatsView: View {
    let entries: [HealthEntry]
    
    var weeklyStats: (avgSteps: Double, avgWater: Double, avgSleep: Double) {
        guard !entries.isEmpty else { return (0, 0, 0) }
        
        let totalSteps = entries.reduce(0) { $0 + $1.steps }
        let totalWater = entries.reduce(0) { $0 + $1.waterIntake }
        let totalSleep = entries.reduce(0) { $0 + $1.sleepHours }
        let count = Double(entries.count)
        
        return (
            avgSteps: Double(totalSteps) / count,
            avgWater: totalWater / count,
            avgSleep: totalSleep / count
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Averages")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                StatCard(
                    icon: "figure.walk",
                    title: "Steps",
                    value: String(format: "%.0f", weeklyStats.avgSteps),
                    color: .green
                )
                
                StatCard(
                    icon: "drop.fill",
                    title: "Water",
                    value: String(format: "%.1fL", weeklyStats.avgWater),
                    color: .blue
                )
                
                StatCard(
                    icon: "bed.double.fill",
                    title: "Sleep",
                    value: String(format: "%.1fh", weeklyStats.avgSleep),
                    color: .purple
                )
            }
        }
    }
}

struct EntriesListView: View {
    let entries: [HealthEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Entries")
                .font(.headline)
                .fontWeight(.semibold)
            
            if entries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.downtrend.xyaxis")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    Text("No entries this week")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Start logging your daily health metrics to see your progress!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
                .background(Color(.systemGray6))
                .cornerRadius(16)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(entries.reversed()) { entry in
                        EntryRowView(entry: entry)
                    }
                }
            }
        }
    }
}

struct EntryRowView: View {
    let entry: HealthEntry
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.formattedDate)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(entry.dayOfWeek)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                if entry.steps > 0 {
                    MetricBadge(
                        icon: "figure.walk",
                        value: "\(entry.steps)",
                        color: .green
                    )
                }
                
                if entry.waterIntake > 0 {
                    MetricBadge(
                        icon: "drop.fill",
                        value: String(format: "%.1fL", entry.waterIntake),
                        color: .blue
                    )
                }
                
                if entry.sleepHours > 0 {
                    MetricBadge(
                        icon: "bed.double.fill",
                        value: String(format: "%.1fh", entry.sleepHours),
                        color: .purple
                    )
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    SummaryView()
        .environmentObject(HealthDataStore())
}
