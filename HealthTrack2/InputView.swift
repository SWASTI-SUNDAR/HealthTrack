//
//  InputView.swift
//  HealthTrack2
//
//  Created by Swasti Sundar Pradhan on 24/05/25.
//

import SwiftUI

struct InputView: View {
    @EnvironmentObject var dataStore: HealthDataStore
    @EnvironmentObject var goalsManager: GoalsManager
    @EnvironmentObject var achievementsManager: AchievementsManager
    @State private var steps: String = ""
    @State private var waterIntake: String = ""
    @State private var sleepHours: String = ""
    @State private var heartRate: String = ""
    @State private var caloriesBurned: String = ""
    @State private var selectedMood: MoodLevel = .neutral
    @State private var weight: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var saveAnimation = false
    @State private var showingAchievement = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Enhanced Header with gradient
                    VStack(spacing: 8) {
                        Text("Daily Health Log")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Track your daily wellness journey")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Goals Progress Card
                    if let todaysEntry = dataStore.getTodaysEntry() {
                        GoalsProgressCard(entry: todaysEntry)
                    }
                    
                    // Input Cards with enhanced design
                    VStack(spacing: 16) {
                        HealthInputCard(
                            icon: "figure.walk",
                            title: "Steps",
                            subtitle: "Daily step count",
                            value: $steps,
                            placeholder: "10000",
                            keyboardType: .numberPad,
                            color: .green
                        )
                        
                        HealthInputCard(
                            icon: "drop.fill",
                            title: "Water Intake",
                            subtitle: "Liters consumed today",
                            value: $waterIntake,
                            placeholder: "2.5",
                            keyboardType: .decimalPad,
                            color: .blue
                        )
                        
                        HealthInputCard(
                            icon: "bed.double.fill",
                            title: "Sleep Hours",
                            subtitle: "Hours of sleep last night",
                            value: $sleepHours,
                            placeholder: "8.0",
                            keyboardType: .decimalPad,
                            color: .purple
                        )
                        
                        HealthInputCard(
                            icon: "heart.fill",
                            title: "Heart Rate",
                            subtitle: "Beats per minute",
                            value: $heartRate,
                            placeholder: "70",
                            keyboardType: .numberPad,
                            color: .red
                        )
                        
                        HealthInputCard(
                            icon: "flame.fill",
                            title: "Calories Burned",
                            subtitle: "Total calories today",
                            value: $caloriesBurned,
                            placeholder: "2000",
                            keyboardType: .numberPad,
                            color: .orange
                        )
                        
                        HealthInputCard(
                            icon: "scalemass.fill",
                            title: "Weight",
                            subtitle: "Current weight in kg",
                            value: $weight,
                            placeholder: "70.0",
                            keyboardType: .decimalPad,
                            color: .brown
                        )
                        
                        // Mood Selector
                        MoodSelectorCard(selectedMood: $selectedMood)
                    }
                    
                    // Enhanced Save Button
                    Button(action: saveEntry) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                            Text("Save Today's Entry")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple, .pink]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        .scaleEffect(saveAnimation ? 0.95 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: saveAnimation)
                    }
                    .padding(.top, 8)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarHidden(true)
            .onAppear(perform: loadTodaysEntry)
            .alert("Health Entry", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .overlay(
                AchievementPopup(
                    achievements: achievementsManager.recentlyUnlocked,
                    isShowing: $showingAchievement
                )
            )
        }
    }
    
    private func saveEntry() {
        guard !steps.isEmpty || !waterIntake.isEmpty || !sleepHours.isEmpty || !heartRate.isEmpty || !caloriesBurned.isEmpty || !weight.isEmpty else {
            alertMessage = "Please enter at least one health metric."
            showingAlert = true
            return
        }
        
        let stepsInt = Int(steps) ?? 0
        let waterDouble = Double(waterIntake) ?? 0.0
        let sleepDouble = Double(sleepHours) ?? 0.0
        let heartRateInt = Int(heartRate) ?? 0
        let caloriesInt = Int(caloriesBurned) ?? 0
        let weightDouble = Double(weight) ?? 0.0
        
        let entry = HealthEntry(
            date: Date(),
            steps: stepsInt,
            waterIntake: waterDouble,
            sleepHours: sleepDouble,
            heartRate: heartRateInt,
            caloriesBurned: caloriesInt,
            mood: selectedMood,
            weight: weightDouble
        )
        
        saveAnimation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            saveAnimation = false
        }
        
        dataStore.addEntry(entry)
        achievementsManager.checkAchievements(entries: dataStore.entries, goals: goalsManager.currentGoals)
        
        if !achievementsManager.recentlyUnlocked.isEmpty {
            showingAchievement = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                achievementsManager.recentlyUnlocked.removeAll()
                showingAchievement = false
            }
        }
        
        alertMessage = "Your health entry has been saved successfully!"
        showingAlert = true
    }
    
    private func loadTodaysEntry() {
        if let todaysEntry = dataStore.getTodaysEntry() {
            steps = todaysEntry.steps > 0 ? String(todaysEntry.steps) : ""
            waterIntake = todaysEntry.waterIntake > 0 ? String(format: "%.1f", todaysEntry.waterIntake) : ""
            sleepHours = todaysEntry.sleepHours > 0 ? String(format: "%.1f", todaysEntry.sleepHours) : ""
            heartRate = todaysEntry.heartRate > 0 ? String(todaysEntry.heartRate) : ""
            caloriesBurned = todaysEntry.caloriesBurned > 0 ? String(todaysEntry.caloriesBurned) : ""
            weight = todaysEntry.weight > 0 ? String(format: "%.1f", todaysEntry.weight) : ""
            selectedMood = todaysEntry.mood
        }
    }
}

struct HealthInputCard: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var value: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            TextField(placeholder, text: $value)
                .font(.title2)
                .fontWeight(.medium)
                .keyboardType(keyboardType)
                .textFieldStyle(RoundedBorderTextFieldStyle())
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

struct MoodSelectorCard: View {
    @Binding var selectedMood: MoodLevel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "face.smiling")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Mood")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("How are you feeling today?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                ForEach(MoodLevel.allCases, id: \.self) { mood in
                    Button(action: {
                        selectedMood = mood
                    }) {
                        VStack(spacing: 4) {
                            Text(mood.emoji)
                                .font(.title)
                            Text(mood.rawValue.prefix(4))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedMood == mood ? mood.color.opacity(0.3) : Color.clear)
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
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
        .shadow(color: .yellow.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

struct GoalsProgressCard: View {
    let entry: HealthEntry
    @EnvironmentObject var goalsManager: GoalsManager
    
    var body: some View {
        let progress = goalsManager.getGoalProgress(for: entry)
        
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(Int(progress.overallProgress * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            ProgressBar(progress: progress.overallProgress, color: .blue)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

struct AchievementPopup: View {
    let achievements: [Achievement]
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing && !achievements.isEmpty {
            VStack {
                Spacer()
                
                ForEach(achievements) { achievement in
                    HStack {
                        Image(systemName: achievement.icon)
                            .font(.title)
                            .foregroundColor(achievement.colorValue)
                        
                        VStack(alignment: .leading) {
                            Text("Achievement Unlocked!")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(achievement.title)
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [achievement.colorValue.opacity(0.2), achievement.colorValue.opacity(0.1)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(radius: 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: isShowing)
        }
    }
}

#Preview {
    InputView()
        .environmentObject(HealthDataStore())
        .environmentObject(GoalsManager())
        .environmentObject(AchievementsManager())
}
