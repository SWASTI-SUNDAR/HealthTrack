import SwiftUI
import Foundation

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .system
    @Published var isDarkMode: Bool = false
    
    enum AppTheme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
        
        var icon: String {
            switch self {
            case .light: return "sun.max.fill"
            case .dark: return "moon.fill"
            case .system: return "gear"
            }
        }
    }
    
    init() {
        loadTheme()
        updateDarkMode()
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        saveTheme()
        updateDarkMode()
    }
    
    private func updateDarkMode() {
        switch currentTheme {
        case .light:
            isDarkMode = false
        case .dark:
            isDarkMode = true
        case .system:
            isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        }
    }
    
    private func saveTheme() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: "AppTheme")
    }
    
    private func loadTheme() {
        let themeString = UserDefaults.standard.string(forKey: "AppTheme") ?? AppTheme.system.rawValue
        currentTheme = AppTheme(rawValue: themeString) ?? .system
    }
}

// Theme Colors
extension Color {
    static var themeBackground: Color {
        Color(.systemBackground)
    }
    
    static var themeSecondaryBackground: Color {
        Color(.secondarySystemBackground)
    }
    
    static var themeTertiary: Color {
        Color(.tertiarySystemBackground)
    }
    
    static var themePrimary: Color {
        Color(.label)
    }
    
    static var themeSecondary: Color {
        Color(.secondaryLabel)
    }
    
    static var themeAccent: Color {
        Color.accentColor
    }
}
