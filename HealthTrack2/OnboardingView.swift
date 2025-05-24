import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    @State private var animateContent = false
    
    let pages = [
        OnboardingPage(
            icon: "heart.fill",
            title: "Welcome to HealthTrack2",
            description: "Your personal health companion for tracking wellness metrics and achieving your goals.",
            color: .pink
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Track Your Progress",
            description: "Log daily metrics like steps, water intake, sleep, and mood to visualize your health journey.",
            color: .blue
        ),
        OnboardingPage(
            icon: "target",
            title: "Set Smart Goals",
            description: "Customize daily targets and track your progress with beautiful visual indicators.",
            color: .green
        ),
        OnboardingPage(
            icon: "trophy.fill",
            title: "Unlock Achievements",
            description: "Stay motivated with gamified progress tracking and celebrate your health milestones.",
            color: .orange
        ),
        OnboardingPage(
            icon: "brain.head.profile",
            title: "Get Smart Insights",
            description: "Receive personalized recommendations based on your health data and patterns.",
            color: .purple
        )
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background
                LinearGradient(
                    colors: [
                        pages[currentPage].color.opacity(0.3),
                        pages[currentPage].color.opacity(0.1),
                        Color.themeBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentPage)
                
                VStack(spacing: 0) {
                    // Progress indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index <= currentPage ? pages[currentPage].color : Color(.systemGray4))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentPage)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Content
                    TabView(selection: $currentPage) {
                        ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                            OnboardingPageView(page: page, animate: animateContent)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .onChange(of: currentPage) { _ in
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            animateContent = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                animateContent = true
                            }
                        }
                    }
                    
                    // Bottom section
                    VStack(spacing: 20) {
                        if currentPage == pages.count - 1 {
                            // Get Started button
                            Button(action: {
                                completeOnboarding()
                            }) {
                                HStack {
                                    Text("Get Started")
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [pages[currentPage].color, pages[currentPage].color.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: pages[currentPage].color.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        } else {
                            // Next button
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    currentPage += 1
                                }
                            }) {
                                HStack {
                                    Text("Next")
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [pages[currentPage].color, pages[currentPage].color.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: pages[currentPage].color.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        }
                        
                        // Skip button
                        Button(action: {
                            completeOnboarding()
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.themeSecondary)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        animateContent = true
                    }
                }
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "HasCompletedOnboarding")
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isPresented = false
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let animate: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [page.color.opacity(0.3), page.color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(animate ? 1.0 : 0.8)
                
                Image(systemName: page.icon)
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(page.color)
                    .scaleEffect(animate ? 1.0 : 0.8)
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animate)
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.themePrimary)
                    .multilineTextAlignment(.center)
                    .opacity(animate ? 1.0 : 0.0)
                    .offset(y: animate ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animate)
                
                Text(page.description)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.themeSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .opacity(animate ? 1.0 : 0.0)
                    .offset(y: animate ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animate)
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
