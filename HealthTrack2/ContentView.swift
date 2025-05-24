import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            InputView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Log Entry")
                }
            
            SummaryView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Summary")
                }
            
            GoalsView()
                .tabItem {
                    Image(systemName: "target")
                    Text("Goals")
                }
            
            AchievementsView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Achievements")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
        .environmentObject(HealthDataStore())
        .environmentObject(GoalsManager())
        .environmentObject(AchievementsManager())
}
