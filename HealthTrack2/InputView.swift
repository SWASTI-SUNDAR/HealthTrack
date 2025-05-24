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
    @State private var pulseAnimation = false
    @State private var cardAnimations: [Bool] = Array(repeating: false, count: 7)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background gradient
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.1),
                        Color.pink.opacity(0.05),
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        // Modern Header
                        headerSection
                        
                        // Progress Card (if exists)
                        if let todaysEntry = dataStore.getTodaysEntry() {
                            ModernGoalsProgressCard(entry: todaysEntry)
                                .scaleEffect(cardAnimations[0] ? 1.0 : 0.8)
                                .opacity(cardAnimations[0] ? 1.0 : 0.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: cardAnimations[0])
                        }
                        
                        // Input Grid
                        inputGridSection
                        
                        // Mood Section
                        modernMoodSection
                        
                        // Save Button
                        modernSaveButton
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadTodaysEntry()
                animateCards()
            }
            .alert("Health Entry", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .overlay(
                ModernAchievementPopup(
                    achievements: achievementsManager.recentlyUnlocked,
                    isShowing: $showingAchievement
                )
            )
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Health Tracker")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Let's log your wellness journey")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Animated wellness icon
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
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: pulseAnimation)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.pink)
                }
                .onAppear {
                    pulseAnimation = true
                }
            }
            
            // Today's date card
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                
                Text("Today, \(Date().formatted(date: .abbreviated, time: .omitted))")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let streakCount = getStreakCount() {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(streakCount) day streak")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.top, 20)
    }
    
    private var inputGridSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ModernHealthCard(
                icon: "figure.walk",
                title: "Steps",
                subtitle: "Daily count",
                value: $steps,
                placeholder: "10,000",
                keyboardType: .numberPad,
                color: .green,
                index: 1
            )
            
            ModernHealthCard(
                icon: "drop.fill",
                title: "Water",
                subtitle: "Liters",
                value: $waterIntake,
                placeholder: "2.5",
                keyboardType: .decimalPad,
                color: .blue,
                index: 2
            )
            
            ModernHealthCard(
                icon: "bed.double.fill",
                title: "Sleep",
                subtitle: "Hours",
                value: $sleepHours,
                placeholder: "8.0",
                keyboardType: .decimalPad,
                color: .purple,
                index: 3
            )
            
            ModernHealthCard(
                icon: "heart.fill",
                title: "Heart Rate",
                subtitle: "BPM",
                value: $heartRate,
                placeholder: "70",
                keyboardType: .numberPad,
                color: .red,
                index: 4
            )
            
            ModernHealthCard(
                icon: "flame.fill",
                title: "Calories",
                subtitle: "Burned",
                value: $caloriesBurned,
                placeholder: "2,000",
                keyboardType: .numberPad,
                color: .orange,
                index: 5
            )
            
            ModernHealthCard(
                icon: "scalemass.fill",
                title: "Weight",
                subtitle: "Kilograms",
                value: $weight,
                placeholder: "70.0",
                keyboardType: .decimalPad,
                color: .brown,
                index: 6
            )
        }
    }
    
    private var modernMoodSection: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "face.smiling")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    
                    Text("How are you feeling?")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                ForEach(MoodLevel.allCases, id: \.self) { mood in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            selectedMood = mood
                        }
                    }) {
                        VStack(spacing: 8) {
                            Text(mood.emoji)
                                .font(.system(size: 28))
                                .scaleEffect(selectedMood == mood ? 1.2 : 1.0)
                            
                            Text(mood.rawValue.prefix(4))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(selectedMood == mood ? mood.color : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedMood == mood ? mood.color.opacity(0.2) : Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedMood == mood ? mood.color : Color.clear, lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMood)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .scaleEffect(cardAnimations[6] ? 1.0 : 0.8)
        .opacity(cardAnimations[6] ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.7), value: cardAnimations[6])
    }
    
    private var modernSaveButton: some View {
        Button(action: saveEntry) {
            HStack(spacing: 12) {
                if saveAnimation {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                }
                
                Text(saveAnimation ? "Saving..." : "Save Today's Entry")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                ZStack {
                    // Animated background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    // Shimmer effect
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.3), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: saveAnimation ? 200 : -200)
                        .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: saveAnimation)
                }
            )
            .scaleEffect(saveAnimation ? 0.98 : 1.0)
            .shadow(color: .blue.opacity(0.4), radius: saveAnimation ? 20 : 15, x: 0, y: saveAnimation ? 10 : 8)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: saveAnimation)
        }
        .disabled(saveAnimation)
        .padding(.top, 20)
    }
    
    // MARK: - Helper Functions
    
    private func animateCards() {
        for i in 0..<cardAnimations.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                withAnimation {
                    cardAnimations[i] = true
                }
            }
        }
    }
    
    private func getStreakCount() -> Int? {
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
        
        return streak > 0 ? streak : nil
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
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            saveAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dataStore.addEntry(entry)
            achievementsManager.checkAchievements(entries: dataStore.entries, goals: goalsManager.currentGoals)
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                saveAnimation = false
            }
            
            if !achievementsManager.recentlyUnlocked.isEmpty {
                showingAchievement = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    achievementsManager.recentlyUnlocked.removeAll()
                    showingAchievement = false
                }
            }
            
            alertMessage = "🎉 Your health entry has been saved successfully!"
            showingAlert = true
        }
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

// MARK: - Modern Components

struct ModernHealthCard: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var value: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let color: Color
    let index: Int
    @State private var isActive = false
    @State private var cardScale = 0.8
    @State private var cardOpacity = 0.0
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon section
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.2), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Title section
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // Input section
            TextField(placeholder, text: $value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .keyboardType(keyboardType)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isActive ? color : Color.clear, lineWidth: 2)
                        )
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isActive = true
                    }
                }
                .onSubmit {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isActive = false
                    }
                }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isActive ? color.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
        .scaleEffect(cardScale)
        .opacity(cardOpacity)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: cardScale)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: cardOpacity)
        .onAppear {
            cardScale = 1.0
            cardOpacity = 1.0
        }
    }
}

struct ModernGoalsProgressCard: View {
    let entry: HealthEntry
    @EnvironmentObject var goalsManager: GoalsManager
    
    var body: some View {
        let progress = goalsManager.getGoalProgress(for: entry)
        
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Progress")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Keep going, you're doing great!")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(progress.overallProgress))
                        .stroke(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: progress.overallProgress)
                    
                    Text("\(Int(progress.overallProgress * 100))%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            
            // Mini progress indicators
            HStack(spacing: 16) {
                MiniProgressIndicator(title: "Steps", progress: progress.stepsProgress, color: .green)
                MiniProgressIndicator(title: "Water", progress: progress.waterProgress, color: .blue)
                MiniProgressIndicator(title: "Sleep", progress: progress.sleepProgress, color: .purple)
                MiniProgressIndicator(title: "Calories", progress: progress.caloriesProgress, color: .orange)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.green.opacity(0.1), .blue.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.green.opacity(0.3), .blue.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

struct MiniProgressIndicator: View {
    let title: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 3)
                    .frame(width: 24, height: 24)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 24, height: 24)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: progress)
            }
            
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

struct ModernAchievementPopup: View {
    let achievements: [Achievement]
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing && !achievements.isEmpty {
            VStack {
                Spacer()
                
                ForEach(achievements) { achievement in
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(achievement.colorValue.opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: achievement.icon)
                                .font(.title2)
                                .foregroundColor(achievement.colorValue)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("🎉 Achievement Unlocked!")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text(achievement.title)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: achievement.colorValue.opacity(0.3), radius: 15, x: 0, y: 8)
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isShowing)
        }
    }
}

#Preview {
    InputView()
        .environmentObject(HealthDataStore())
        .environmentObject(GoalsManager())
        .environmentObject(AchievementsManager())
}
