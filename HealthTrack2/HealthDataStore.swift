//
//  HealthDataStore.swift
//  HealthTrack2
//
//  Created by Swasti Sundar Pradhan on 24/05/25.
//


import Foundation
import SwiftUI

class HealthDataStore: ObservableObject {
    @Published var entries: [HealthEntry] = []
    private let userDefaults = UserDefaults.standard
    private let entriesKey = "HealthEntries"
    
    init() {
        loadEntries()
    }
    
    func addEntry(_ entry: HealthEntry) {
        // Check if entry for today already exists
        if let existingIndex = entries.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: entry.date) }) {
            entries[existingIndex] = entry
        } else {
            entries.append(entry)
        }
        entries.sort { $0.date > $1.date }
        saveEntries()
    }
    
    func deleteEntry(_ entry: HealthEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    func getTodaysEntry() -> HealthEntry? {
        return entries.first { Calendar.current.isDate($0.date, inSameDayAs: Date()) }
    }
    
    func getWeeklyEntries() -> [HealthEntry] {
        let calendar = Calendar.current
        let today = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        
        return entries.filter { $0.date >= weekAgo && $0.date <= today }
            .sorted { $0.date < $1.date }
    }
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            userDefaults.set(encoded, forKey: entriesKey)
        }
    }
    
    private func loadEntries() {
        if let data = userDefaults.data(forKey: entriesKey),
           let decoded = try? JSONDecoder().decode([HealthEntry].self, from: data) {
            entries = decoded.sorted { $0.date > $1.date }
        }
    }
}