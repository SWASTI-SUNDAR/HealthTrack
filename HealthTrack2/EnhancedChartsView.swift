import SwiftUI
import Charts

struct AdvancedChartsView: View {
    let entries: [HealthEntry]
    @State private var selectedMetric: ChartMetric = .steps
    @State private var selectedTimeframe: ChartTimeframe = .week
    @State private var animateChart = false
    
    enum ChartMetric: String, CaseIterable {
        case steps = "Steps"
        case water = "Water"
        case sleep = "Sleep"
        case heartRate = "Heart Rate"
        case calories = "Calories"
        case weight = "Weight"
        case mood = "Mood"
        
        var icon: String {
            switch self {
            case .steps: return "figure.walk"
            case .water: return "drop.fill"
            case .sleep: return "bed.double.fill"
            case .heartRate: return "heart.fill"
            case .calories: return "flame.fill"
            case .weight: return "scalemass.fill"
            case .mood: return "face.smiling"
            }
        }
        
        var color: Color {
            switch self {
            case .steps: return .green
            case .water: return .blue
            case .sleep: return .purple
            case .heartRate: return .red
            case .calories: return .orange
            case .weight: return .brown
            case .mood: return .yellow
            }
        }
    }
    
    enum ChartTimeframe: String, CaseIterable {
        case week = "7D"
        case month = "30D"
        case threeMonths = "90D"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .threeMonths: return 90
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header with controls
            headerSection
            
            // Enhanced chart
            chartSection
            
            // Statistics cards
            statisticsSection
            
            // Trend analysis
            trendAnalysisSection
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animateChart = true
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Metric selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ChartMetric.allCases, id: \.self) { metric in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedMetric = metric
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: metric.icon)
                                    .font(.system(size: 14, weight: .medium))
                                Text(metric.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(selectedMetric == metric ? .white : metric.color)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedMetric == metric ? 
                                          metric.color : 
                                          metric.color.opacity(0.15)
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Timeframe selector
            HStack(spacing: 8) {
                ForEach(ChartTimeframe.allCases, id: \.self) { timeframe in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTimeframe = timeframe
                        }
                    }) {
                        Text(timeframe.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(selectedTimeframe == timeframe ? .white : .themeSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedTimeframe == timeframe ? 
                                          selectedMetric.color : 
                                          Color.themeSecondaryBackground
                                    )
                            )
                    }
                }
            }
        }
    }
    
    private var chartSection: some View {
        let filteredEntries = getFilteredEntries()
        let chartData = getChartData(for: selectedMetric, entries: filteredEntries)
        
        return VStack(spacing: 16) {
            HStack {
                Text("\(selectedMetric.rawValue) Trend")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.themePrimary)
                
                Spacer()
                
                if !chartData.isEmpty {
                    Text("\(chartData.count) entries")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.themeSecondary)
                }
            }
            
            if chartData.isEmpty {
                EmptyChartView(metric: selectedMetric)
            } else {
                if #available(iOS 16.0, *) {
                    Chart {
                        ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                            LineMark(
                                x: .value("Date", data.date),
                                y: .value(selectedMetric.rawValue, animateChart ? data.value : 0)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [selectedMetric.color, selectedMetric.color.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                            .symbol(Circle().strokeBorder(lineWidth: 2))
                            
                            AreaMark(
                                x: .value("Date", data.date),
                                y: .value(selectedMetric.rawValue, animateChart ? data.value : 0)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [selectedMetric.color.opacity(0.3), selectedMetric.color.opacity(0.05)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                    }
                    .frame(height: 200)
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                            AxisValueLabel()
                        }
                    }
                    .chartXAxis {
                        AxisMarks { value in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        }
                    }
                    .animation(.easeInOut(duration: 1.0), value: animateChart)
                } else {
                    // Fallback for older iOS versions
                    LegacyChartView(data: chartData, metric: selectedMetric, animate: animateChart)
                        .frame(height: 200)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.themeBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var statisticsSection: some View {
        let filteredEntries = getFilteredEntries()
        let stats = calculateStatistics(for: selectedMetric, entries: filteredEntries)
        
        return LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatisticCard(
                title: "Average",
                value: stats.average,
                icon: "chart.bar.fill",
                color: selectedMetric.color
            )
            
            StatisticCard(
                title: "Best",
                value: stats.maximum,
                icon: "arrow.up.circle.fill",
                color: .green
            )
            
            StatisticCard(
                title: "Trend",
                value: stats.trend,
                icon: stats.trendDirection == .up ? "arrow.up.right" : stats.trendDirection == .down ? "arrow.down.right" : "minus",
                color: stats.trendDirection == .up ? .green : stats.trendDirection == .down ? .red : .gray
            )
        }
    }
    
    private var trendAnalysisSection: some View {
        let filteredEntries = getFilteredEntries()
        let analysis = getTrendAnalysis(for: selectedMetric, entries: filteredEntries)
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Trend Analysis")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.themePrimary)
            
            VStack(spacing: 12) {
                ForEach(analysis, id: \.title) { insight in
                    TrendInsightCard(insight: insight)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func getFilteredEntries() -> [HealthEntry] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -selectedTimeframe.days, to: endDate) ?? endDate
        
        return entries.filter { entry in
            entry.date >= startDate && entry.date <= endDate
        }.sorted { $0.date < $1.date }
    }
    
    private func getChartData(for metric: ChartMetric, entries: [HealthEntry]) -> [ChartDataPoint] {
        return entries.compactMap { entry in
            let value: Double
            switch metric {
            case .steps: value = Double(entry.steps)
            case .water: value = entry.waterIntake
            case .sleep: value = entry.sleepHours
            case .heartRate: value = Double(entry.heartRate)
            case .calories: value = Double(entry.caloriesBurned)
            case .weight: value = entry.weight
            case .mood:
                switch entry.mood {
                case .veryHappy: value = 5.0
                case .happy: value = 4.0
                case .neutral: value = 3.0
                case .sad: value = 2.0
                case .verySad: value = 1.0
                }
            }
            
            return value > 0 ? ChartDataPoint(date: entry.date, value: value) : nil
        }
    }
    
    private func calculateStatistics(for metric: ChartMetric, entries: [HealthEntry]) -> ChartStatistics {
        let data = getChartData(for: metric, entries: entries)
        guard !data.isEmpty else { 
            return ChartStatistics(average: "N/A", maximum: "N/A", trend: "N/A", trendDirection: .neutral)
        }
        
        let values = data.map { $0.value }
        let average = values.reduce(0, +) / Double(values.count)
        let maximum = values.max() ?? 0
        
        // Calculate trend
        let midPoint = data.count / 2
        let firstHalf = Array(data.prefix(midPoint))
        let secondHalf = Array(data.suffix(midPoint))
        
        let firstAvg = firstHalf.isEmpty ? 0 : firstHalf.map { $0.value }.reduce(0, +) / Double(firstHalf.count)
        let secondAvg = secondHalf.isEmpty ? 0 : secondHalf.map { $0.value }.reduce(0, +) / Double(secondHalf.count)
        
        let trendValue = secondAvg - firstAvg
        let trendDirection: TrendDirection = abs(trendValue) < 0.1 ? .neutral : trendValue > 0 ? .up : .down
        
        return ChartStatistics(
            average: formatValue(average, for: metric),
            maximum: formatValue(maximum, for: metric),
            trend: formatTrendValue(trendValue, for: metric),
            trendDirection: trendDirection
        )
    }
    
    private func formatValue(_ value: Double, for metric: ChartMetric) -> String {
        switch metric {
        case .steps, .heartRate, .calories:
            return String(format: "%.0f", value)
        case .water, .sleep, .weight:
            return String(format: "%.1f", value)
        case .mood:
            return String(format: "%.1f/5", value)
        }
    }
    
    private func formatTrendValue(_ value: Double, for metric: ChartMetric) -> String {
        let prefix = value > 0 ? "+" : ""
        switch metric {
        case .steps, .heartRate, .calories:
            return "\(prefix)\(String(format: "%.0f", value))"
        case .water, .sleep, .weight:
            return "\(prefix)\(String(format: "%.1f", value))"
        case .mood:
            return "\(prefix)\(String(format: "%.1f", value))"
        }
    }
    
    private func getTrendAnalysis(for metric: ChartMetric, entries: [HealthEntry]) -> [TrendInsight] {
        // Implement trend analysis logic here
        return []
    }
}

struct ChartDataPoint {
    let date: Date
    let value: Double
}

struct ChartStatistics {
    let average: String
    let maximum: String
    let trend: String
    let trendDirection: TrendDirection
}

enum TrendDirection {
    case up, down, neutral
}

struct TrendInsight {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.themePrimary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.themeSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.themeSecondaryBackground)
        )
    }
}

struct TrendInsightCard: View {
    let insight: TrendInsight
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: insight.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(insight.color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(insight.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.themePrimary)
                
                Text(insight.description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.themeSecondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(insight.color.opacity(0.1))
        )
    }
}

struct EmptyChartView: View {
    let metric: AdvancedChartsView.ChartMetric
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: metric.icon)
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(.themeSecondary)
            
            Text("No \(metric.rawValue) Data")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.themePrimary)
            
            Text("Start logging your \(metric.rawValue.lowercased()) to see trends here")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.themeSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
    }
}

struct LegacyChartView: View {
    let data: [ChartDataPoint]
    let metric: AdvancedChartsView.ChartMetric
    let animate: Bool
    
    var maxValue: Double {
        data.map { $0.value }.max() ?? 1
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, point in
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [metric.color, metric.color.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 16, height: CGFloat((animate ? point.value : 0) / maxValue * 160))
                        .animation(.easeInOut(duration: 0.8).delay(Double(index) * 0.1), value: animate)
                    
                    Text(DateFormatter.dayMonth.string(from: point.date))
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.themeSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

extension DateFormatter {
    static let dayMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter
    }()
}
