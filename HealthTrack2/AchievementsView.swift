import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var achievementsManager: AchievementsManager
    
    var unlockedAchievements: [Achievement] {
        achievementsManager.achievements.filter { $0.isUnlocked }
    }
    
    var lockedAchievements: [Achievement] {
        achievementsManager.achievements.filter { !$0.isUnlocked }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Achievements")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Your health journey milestones")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Progress Overview
                    AchievementProgressCard(
                        unlocked: unlockedAchievements.count,
                        total: achievementsManager.achievements.count
                    )
                    
                    // Unlocked Achievements
                    if !unlockedAchievements.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Unlocked")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            LazyVStack(spacing: 12) {
                                ForEach(unlockedAchievements.sorted(by: { $0.dateUnlocked ?? Date.distantPast > $1.dateUnlocked ?? Date.distantPast })) { achievement in
                                    AchievementCard(achievement: achievement, isUnlocked: true)
                                }
                            }
                        }
                    }
                    
                    // Locked Achievements
                    if !lockedAchievements.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Locked")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            
                            LazyVStack(spacing: 12) {
                                ForEach(lockedAchievements) { achievement in
                                    AchievementCard(achievement: achievement, isUnlocked: false)
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarHidden(true)
        }
    }
}

struct AchievementProgressCard: View {
    let unlocked: Int
    let total: Int
    
    var progress: Double {
        guard total > 0 else { return 0 }
        return Double(unlocked) / Double(total)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Achievement Progress")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("\(unlocked) of \(total) unlocked")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            ProgressBar(progress: progress, color: .yellow)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [.yellow.opacity(0.1), .orange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.yellow.opacity(0.3), .orange.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: achievement.icon)
                .font(.title)
                .foregroundColor(isUnlocked ? achievement.colorValue : .gray)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(
                            isUnlocked ?
                            LinearGradient(
                                colors: [achievement.colorValue.opacity(0.3), achievement.colorValue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                if isUnlocked, let date = achievement.dateUnlocked {
                    Text("Unlocked \(date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(achievement.colorValue)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            // Badge
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(achievement.colorValue)
            } else {
                Image(systemName: "lock.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: isUnlocked ?
                [Color(.systemGray6), Color(.systemGray5)] :
                [Color(.systemGray5), Color(.systemGray4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isUnlocked ? achievement.colorValue.opacity(0.3) : Color.gray.opacity(0.2),
                    lineWidth: 1
                )
        )
        .scaleEffect(isUnlocked ? 1.0 : 0.95)
        .opacity(isUnlocked ? 1.0 : 0.7)
    }
}

#Preview {
    AchievementsView()
        .environmentObject(AchievementsManager())
}
