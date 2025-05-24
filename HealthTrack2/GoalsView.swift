import SwiftUI

struct GoalsView: View {
    @EnvironmentObject var goalsManager: GoalsManager
    @EnvironmentObject var dataStore: HealthDataStore
    @State private var editingGoals = false
    @State private var tempGoals = HealthGoal()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Health Goals")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Set and track your daily targets")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Current Progress
                    if let todaysEntry = dataStore.getTodaysEntry() {
                        TodaysProgressCard(entry: todaysEntry)
                    }
                    
                    // Goals Cards
                    VStack(spacing: 16) {
                        GoalCard(
                            icon: "figure.walk",
                            title: "Steps",
                            current: Double(dataStore.getTodaysEntry()?.steps ?? 0),
                            target: Double(goalsManager.currentGoals.steps),
                            color: .green,
                            format: { "\(Int($0))" }
                        )
                        
                        GoalCard(
                            icon: "drop.fill",
                            title: "Water",
                            current: dataStore.getTodaysEntry()?.waterIntake ?? 0,
                            target: goalsManager.currentGoals.waterIntake,
                            color: .blue,
                            format: { String(format: "%.1fL", $0) }
                        )
                        
                        GoalCard(
                            icon: "bed.double.fill",
                            title: "Sleep",
                            current: dataStore.getTodaysEntry()?.sleepHours ?? 0,
                            target: goalsManager.currentGoals.sleepHours,
                            color: .purple,
                            format: { String(format: "%.1fh", $0) }
                        )
                        
                        GoalCard(
                            icon: "flame.fill",
                            title: "Calories",
                            current: Double(dataStore.getTodaysEntry()?.caloriesBurned ?? 0),
                            target: Double(goalsManager.currentGoals.caloriesBurned),
                            color: .orange,
                            format: { "\(Int($0))" }
                        )
                    }
                    
                    // Edit Goals Button
                    Button(action: {
                        tempGoals = goalsManager.currentGoals
                        editingGoals = true
                    }) {
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                            Text("Edit Goals")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $editingGoals) {
                GoalsEditView(goals: $tempGoals) {
                    goalsManager.updateGoals(tempGoals)
                    editingGoals = false
                }
            }
        }
    }
}

struct TodaysProgressCard: View {
    let entry: HealthEntry
    @EnvironmentObject var goalsManager: GoalsManager
    
    var body: some View {
        let progress = goalsManager.getGoalProgress(for: entry)
        
        VStack(spacing: 16) {
            HStack {
                Text("Today's Overall Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(Int(progress.overallProgress * 100))%")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            ProgressBar(progress: progress.overallProgress, color: .green)
            
            HStack(spacing: 16) {
                ProgressIndicator(title: "Steps", progress: progress.stepsProgress, color: .green)
                ProgressIndicator(title: "Water", progress: progress.waterProgress, color: .blue)
                ProgressIndicator(title: "Sleep", progress: progress.sleepProgress, color: .purple)
                ProgressIndicator(title: "Calories", progress: progress.caloriesProgress, color: .orange)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [.green.opacity(0.1), .blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.green.opacity(0.3), .blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

struct ProgressIndicator: View {
    let title: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 3)
                    .frame(width: 30, height: 30)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 30, height: 30)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progress)
            }
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct GoalCard: View {
    let icon: String
    let title: String
    let current: Double
    let target: Double
    let color: Color
    let format: (Double) -> String
    
    var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("Daily Target")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(format(current))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                    Text("of \(format(target))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ProgressBar(progress: progress, color: color)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(.systemGray6), Color(.systemGray5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: color.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

struct GoalsEditView: View {
    @Binding var goals: HealthGoal
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Targets") {
                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.green)
                        Text("Steps")
                        Spacer()
                        TextField("Steps", value: $goals.steps, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.blue)
                        Text("Water (L)")
                        Spacer()
                        TextField("Water", value: $goals.waterIntake, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Image(systemName: "bed.double.fill")
                            .foregroundColor(.purple)
                        Text("Sleep (hours)")
                        Spacer()
                        TextField("Sleep", value: $goals.sleepHours, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Calories")
                        Spacer()
                        TextField("Calories", value: $goals.caloriesBurned, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Edit Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    GoalsView()
        .environmentObject(GoalsManager())
        .environmentObject(HealthDataStore())
}
