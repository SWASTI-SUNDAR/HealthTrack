//
//  InputView.swift
//  HealthTrack2
//
//  Created by Swasti Sundar Pradhan on 24/05/25.
//

import SwiftUI

struct InputView: View {
    @EnvironmentObject var dataStore: HealthDataStore
    @State private var steps: String = ""
    @State private var waterIntake: String = ""
    @State private var sleepHours: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var saveAnimation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Daily Health Log")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Track your daily wellness journey")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Input Cards
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
                    }
                    
                    // Save Button
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
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .scaleEffect(saveAnimation ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: saveAnimation)
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
        }
    }
    
    private func saveEntry() {
        guard !steps.isEmpty || !waterIntake.isEmpty || !sleepHours.isEmpty else {
            alertMessage = "Please enter at least one health metric."
            showingAlert = true
            return
        }
        
        let stepsInt = Int(steps) ?? 0
        let waterDouble = Double(waterIntake) ?? 0.0
        let sleepDouble = Double(sleepHours) ?? 0.0
        
        let entry = HealthEntry(
            date: Date(),
            steps: stepsInt,
            waterIntake: waterDouble,
            sleepHours: sleepDouble
        )
        
        saveAnimation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            saveAnimation = false
        }
        
        dataStore.addEntry(entry)
        alertMessage = "Your health entry has been saved successfully!"
        showingAlert = true
    }
    
    private func loadTodaysEntry() {
        if let todaysEntry = dataStore.getTodaysEntry() {
            steps = todaysEntry.steps > 0 ? String(todaysEntry.steps) : ""
            waterIntake = todaysEntry.waterIntake > 0 ? String(format: "%.1f", todaysEntry.waterIntake) : ""
            sleepHours = todaysEntry.sleepHours > 0 ? String(format: "%.1f", todaysEntry.sleepHours) : ""
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
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.1))
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
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    InputView()
        .environmentObject(HealthDataStore())
}
