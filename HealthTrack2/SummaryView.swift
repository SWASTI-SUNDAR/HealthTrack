import SwiftUI
import Charts

struct SummaryView: View {
    @EnvironmentObject var dataStore: HealthDataStore
    @EnvironmentObject var goalsManager: GoalsManager
    @State private var selectedMetric: HealthMetric = .steps
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedEntry: HealthEntry? = nil
    @State private var animateCharts = false
    @State private var showingDetails = false
    
    enum HealthMetric: String, CaseIterable {
        case steps = "Steps"
        case water = "Water (L)"
        case sleep = "Sleep (hrs)"
        case heartRate = "Heart Rate"
        case calories = "Calories"
        case weight = "Weight (kg)"
        
        var icon: String {
            switch self {
            case .steps: return "figure.walk"
            case .water: return "drop.fill"
            case .sleep: return "bed.double.fill"
            case .heartRate: return "heart.fill"
            case .calories: return "flame.fill"
            case .weight: return "scalemass.fill"
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
            }
        }
    }
    
    enum TimeRange: String, CaseIterable {
        case week = "7 Days"
        case month = "30 Days"
        case threeMonths = "3 Months"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .threeMonths: return 90
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.05),
                        Color.pink.opacity(0.02),
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        // Modern Header
                        modernHeaderSection
                        
                        // Time Range Selector
                        timeRangeSelectorSection
                        
                        // Overview Cards
                        overviewCardsSection
                        
                        // Interactive Chart Section
                        chartSection
                        
                        // Detailed Analytics
                        analyticsSection
                        
                        // Recent Entries with Enhanced Design
                        recentEntriesSection
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8)) {
                    animateCharts = true
                }
            }
            .sheet(isPresented: $showingDetails) {
                if let entry = selectedEntry {
                    EntryDetailView(entry: entry)
                }
            }
        }
    }
    
    private var modernHeaderSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Health Summary")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Your wellness journey insights")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Animated summary icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.blue)
                        .scaleEffect(animateCharts ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateCharts)
                }
            }
            
            // Period Summary Card
            let entries = getEntriesForTimeRange()
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(entries.count)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.blue)
                    Text("Entries")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(spacing: 4) {
                    Text("\(getConsistencyPercentage())%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.green)
                    Text("Consistency")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(spacing: 4) {
                    Text("\(getCurrentStreak())")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.orange)
                    Text("Day Streak")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
        .padding(.top, 20)
    }
    
    private var timeRangeSelectorSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTimeRange = range
                        }
                    }) {
                        Text(range.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(selectedTimeRange == range ? .white : .primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedTimeRange == range ? 
                                          LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing) :
                                          LinearGradient(colors: [Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var overviewCardsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            let entries = getEntriesForTimeRange()
            let stats = calculateStats(for: entries)
            
            OverviewCard(
                title: "Avg Steps",
                value: String(format: "%.0f", stats.avgSteps),
                icon: "figure.walk",
                color: .green,
                trend: getTrend(for: .steps, entries: entries),
                progress: min(stats.avgSteps / Double(goalsManager.currentGoals.steps), 1.0)
            )
            
            OverviewCard(
                title: "Avg Water",
                value: String(format: "%.1fL", stats.avgWater),
                icon: "drop.fill",
                color: .blue,
                trend: getTrend(for: .water, entries: entries),
                progress: min(stats.avgWater / goalsManager.currentGoals.waterIntake, 1.0)
            )
            
            OverviewCard(
                title: "Avg Sleep",
                value: String(format: "%.1fh", stats.avgSleep),
                icon: "bed.double.fill",
                color: .purple,
                trend: getTrend(for: .sleep, entries: entries),
                progress: min(stats.avgSleep / goalsManager.currentGoals.sleepHours, 1.0)
            )
            
            OverviewCard(
                title: "Avg Calories",
                value: String(format: "%.0f", stats.avgCalories),
                icon: "flame.fill",
                color: .orange,
                trend: getTrend(for: .calories, entries: entries),
                progress: min(stats.avgCalories / Double(goalsManager.currentGoals.caloriesBurned), 1.0)
            )
        }
    }
    
    private var chartSection: some View {
        VStack(spacing: 20) {
            // Metric Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(HealthMetric.allCases, id: \.self) { metric in
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
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedMetric == metric ? metric.color : metric.color.opacity(0.1))
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Enhanced Chart
            EnhancedChartView(
                metric: selectedMetric,
                entries: getEntriesForTimeRange(),
                animate: animateCharts
            )
            .frame(height: 280)
        }
    }
    
    private var analyticsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Analytics")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            let entries = getEntriesForTimeRange()
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                AnalyticsCard(
                    title: "Best Day",
                    subtitle: getBestDay(entries: entries),
                    icon: "star.fill",
                    color: .yellow
                )
                
                AnalyticsCard(
                    title: "Most Active",
                    subtitle: getMostActiveTimeframe(entries: entries),
                    icon: "bolt.fill",
                    color: .orange
                )
                
                AnalyticsCard(
                    title: "Goals Met",
                    subtitle: "\(getGoalsMet(entries: entries))/\(entries.count) days",
                    icon: "target",
                    color: .green
                )
                
                AnalyticsCard(
                    title: "Mood Score",
                    subtitle: String(format: "%.1f/5.0", getAverageMoodScore(entries: entries)),
                    icon: "face.smiling",
                    color: .pink
                )
            }
        }
    }
    
    private var recentEntriesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Entries")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            let entries = getEntriesForTimeRange()
            
            if entries.isEmpty {
                EmptyStateView()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(entries.prefix(5).reversed()) { entry in
                        ModernEntryRow(entry: entry) {
                            selectedEntry = entry
                            showingDetails = true
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func getEntriesForTimeRange() -> [HealthEntry] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -selectedTimeRange.days, to: endDate) ?? endDate
        
        return dataStore.entries.filter { entry in
            entry.date >= startDate && entry.date <= endDate
        }.sorted { $0.date < $1.date }
    }
    
    private func calculateStats(for entries: [HealthEntry]) -> (avgSteps: Double, avgWater: Double, avgSleep: Double, avgCalories: Double) {
        guard !entries.isEmpty else { return (0, 0, 0, 0) }
        
        let totalSteps = entries.reduce(0) { $0 + $1.steps }
        let totalWater = entries.reduce(0) { $0 + $1.waterIntake }
        let totalSleep = entries.reduce(0) { $0 + $1.sleepHours }
        let totalCalories = entries.reduce(0) { $0 + $1.caloriesBurned }
        let count = Double(entries.count)
        
        return (
            avgSteps: Double(totalSteps) / count,
            avgWater: totalWater / count,
            avgSleep: totalSleep / count,
            avgCalories: Double(totalCalories) / count
        )
    }
    
    private func getTrend(for metric: HealthMetric, entries: [HealthEntry]) -> Double {
        guard entries.count > 1 else { return 0 }
        
        let midPoint = entries.count / 2
        let firstHalf = Array(entries.prefix(midPoint))
        let secondHalf = Array(entries.suffix(midPoint))
        
        let firstAvg = getAverageValue(for: metric, entries: firstHalf)
        let secondAvg = getAverageValue(for: metric, entries: secondHalf)
        
        return secondAvg - firstAvg
    }
    
    private func getAverageValue(for metric: HealthMetric, entries: [HealthEntry]) -> Double {
        guard !entries.isEmpty else { return 0 }
        
        let total = entries.reduce(0.0) { result, entry in
            switch metric {
            case .steps: return result + Double(entry.steps)
            case .water: return result + entry.waterIntake
            case .sleep: return result + entry.sleepHours
            case .heartRate: return result + Double(entry.heartRate)
            case .calories: return result + Double(entry.caloriesBurned)
            case .weight: return result + entry.weight
            }
        }
        
        return total / Double(entries.count)
    }
    
    private func getConsistencyPercentage() -> Int {
        let entries = getEntriesForTimeRange()
        let totalDays = selectedTimeRange.days
        return Int((Double(entries.count) / Double(totalDays)) * 100)
    }
    
    private func getCurrentStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        for _ in 0..<30 {
            if dataStore.entries.contains(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                streak += 1
            } else {
                break
            }
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        return streak
    }
    
    private func getBestDay(entries: [HealthEntry]) -> String {
        guard let bestEntry = entries.max(by: { first, second in
            let firstScore = calculateDayScore(first)
            let secondScore = calculateDayScore(second)
            return firstScore < secondScore
        }) else { return "N/A" }
        
        return bestEntry.dayOfWeek
    }
    
    private func calculateDayScore(_ entry: HealthEntry) -> Double {
        let goals = goalsManager.currentGoals
        let stepsScore = min(Double(entry.steps) / Double(goals.steps), 1.0)
        let waterScore = min(entry.waterIntake / goals.waterIntake, 1.0)
        let sleepScore = min(entry.sleepHours / goals.sleepHours, 1.0)
        let caloriesScore = min(Double(entry.caloriesBurned) / Double(goals.caloriesBurned), 1.0)
        
        return (stepsScore + waterScore + sleepScore + caloriesScore) / 4.0
    }
    
    private func getMostActiveTimeframe(entries: [HealthEntry]) -> String {
        // Group entries by day of week and find the most active
        let grouped = Dictionary(grouping: entries) { $0.dayOfWeek }
        let averages = grouped.mapValues { dayEntries in
            dayEntries.reduce(0) { $0 + $1.steps } / dayEntries.count
        }
        
        return averages.max(by: { $0.value < $1.value })?.key ?? "N/A"
    }
    
    private func getGoalsMet(entries: [HealthEntry]) -> Int {
        return entries.filter { entry in
            let progress = goalsManager.getGoalProgress(for: entry)
            return progress.overallProgress >= 0.8 // 80% of goals met
        }.count
    }
    
    private func getAverageMoodScore(entries: [HealthEntry]) -> Double {
        guard !entries.isEmpty else { return 0 }
        
        let totalScore = entries.reduce(0.0) { result, entry in
            switch entry.mood {
            case .veryHappy: return result + 5.0
            case .happy: return result + 4.0
            case .neutral: return result + 3.0
            case .sad: return result + 2.0
            case .verySad: return result + 1.0
            }
        }
        
        return totalScore / Double(entries.count)
    }
}

// MARK: - Enhanced Components

struct OverviewCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: Double
    let progress: Double
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(trend >= 0 ? .green : .red)
                        
                        Text(String(format: "%.1f", abs(trend)))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color.opacity(0.2))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(min(progress, 1.0)), height: 4)
                        .animation(.easeInOut(duration: 1.0), value: progress)
                }
            }
            .frame(height: 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

struct EnhancedChartView: View {
    let metric: SummaryView.HealthMetric
    let entries: [HealthEntry]
    let animate: Bool
    
    var chartData: [(String, Double)] {
        entries.map { entry in
            let value: Double
            switch metric {
            case .steps: value = Double(entry.steps)
            case .water: value = entry.waterIntake
            case .sleep: value = entry.sleepHours
            case .heartRate: value = Double(entry.heartRate)
            case .calories: value = Double(entry.caloriesBurned)
            case .weight: value = entry.weight
            }
            return (entry.dayOfWeek, value)
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("\(metric.rawValue) Trend")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !chartData.isEmpty {
                    Text("Last \(chartData.count) entries")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            if chartData.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.downtrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No data available")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
            } else {
                if #available(iOS 16.0, *) {
                    Chart {
                        ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                            LineMark(
                                x: .value("Day", data.0),
                                y: .value(metric.rawValue, animate ? data.1 : 0)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [metric.color, metric.color.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                            
                            AreaMark(
                                x: .value("Day", data.0),
                                y: .value(metric.rawValue, animate ? data.1 : 0)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [metric.color.opacity(0.3), metric.color.opacity(0.1)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                    }
                    .frame(height: 200)
                    .animation(.easeInOut(duration: 1.5), value: animate)
                } else {
                    // Fallback for older iOS versions
                    SimpleEnhancedChartView(metric: metric, chartData: chartData, animate: animate)
                        .frame(height: 200)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

struct SimpleEnhancedChartView: View {
    let metric: SummaryView.HealthMetric
    let chartData: [(String, Double)]
    let animate: Bool
    
    var maxValue: Double {
        chartData.map(\.1).max() ?? 1
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [metric.color, metric.color.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 24, height: CGFloat((animate ? data.1 : 0) / maxValue * 160))
                        .animation(.easeInOut(duration: 1.0).delay(Double(index) * 0.1), value: animate)
                    
                    Text(data.0)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct AnalyticsCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 35, height: 35)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(subtitle)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
        )
    }
}

struct ModernEntryRow: View {
    let entry: HealthEntry
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Date section
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.formattedDate)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(entry.dayOfWeek)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Metrics preview
                HStack(spacing: 8) {
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
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 8) {
                Text("No Data Yet")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Start logging your health metrics to see beautiful insights and trends here!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

struct EntryDetailView: View {
    let entry: HealthEntry
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text(entry.formattedDate)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(entry.dayOfWeek)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Metrics Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        DetailMetricCard(title: "Steps", value: "\(entry.steps)", icon: "figure.walk", color: .green)
                        DetailMetricCard(title: "Water", value: String(format: "%.1fL", entry.waterIntake), icon: "drop.fill", color: .blue)
                        DetailMetricCard(title: "Sleep", value: String(format: "%.1fh", entry.sleepHours), icon: "bed.double.fill", color: .purple)
                        DetailMetricCard(title: "Heart Rate", value: "\(entry.heartRate) BPM", icon: "heart.fill", color: .red)
                        DetailMetricCard(title: "Calories", value: "\(entry.caloriesBurned)", icon: "flame.fill", color: .orange)
                        DetailMetricCard(title: "Weight", value: String(format: "%.1f kg", entry.weight), icon: "scalemass.fill", color: .brown)
                    }
                    
                    // Mood Section
                    VStack(spacing: 12) {
                        HStack {
                            Text("Mood")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        
                        HStack {
                            Text(entry.mood.emoji)
                                .font(.system(size: 40))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.mood.rawValue)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text("How you felt this day")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(entry.mood.color.opacity(0.1))
                        )
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
}

struct DetailMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    SummaryView()
        .environmentObject(HealthDataStore())
        .environmentObject(GoalsManager())
}
