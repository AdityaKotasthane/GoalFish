//
//  OnboardingView.swift
//  FocusFish
//
//  Created by Arjun Pratap Choudhary on 24/02/25.
//


import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0
    
    
    let pages = [
        OnboardingPage(
            title: "Welcome to GoalFish!",
            subtitle: "Turn Focus into Fun",
            description: "Swipe through to see how GoalFish makes productivity engaging.",
            animationName: "fish-family"
        ),
        OnboardingPage(
            title: "Your Journey Begins",
            subtitle: "Pick Your Fish Companion",
            description: "Choose a fish to accompany you on your focus journey. The more tasks you complete, the more fishes you can get!",
            animationName: "adhd-thoughts"
        ),
        OnboardingPage(
            title: "Stay on Track",
            subtitle: "Complete Tasks, Earn Rewards",
            description: "Set time blocks for work and keep your fish thriving by staying focused. Earn shells and unlock new underwater friends!",
            animationName: "task-rewards"
        ),
        OnboardingPage(
            title: "Your Focus Oasis",
            subtitle: "Build a World That Grows with You",
            description: "Every completed task helps your fish and environment flourish. Create a personalized, calming underwater sanctuary!",
            animationName: "steps-guide"
        ),
        OnboardingPage(
            title: "Let’s Get Started!",
            subtitle: "Begin Your First Session",
            description: "Start your journey now! Set a goal, dive in, and watch your progress come to life.",
            animationName: "focus-oasis"
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            // Content
            VStack(spacing: 0) {
                // Page Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Navigation Buttons
                HStack(spacing: 20) {
                    // Page Indicators with animation
                    HStack(spacing: 10) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.blue : Color.gray.opacity(0.5))
                                .frame(width: currentPage == index ? 12 : 8, height: currentPage == index ? 12 : 8)
                                .animation(.spring(), value: currentPage)
                                .shadow(color: currentPage == index ? .blue.opacity(0.5) : .clear, radius: 5)
                        }
                    }
                    
                    Spacer()
                    
                    // Enhanced Get Started/Next button
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            withAnimation {
                                isOnboardingComplete = true
                            }
                        }
                    }) {
                        Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue, Color.blue.opacity(0.8)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let animationName: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    private var animationScale: CGFloat {
        switch page.animationName {
        case "adhd-thoughts":
            return 1.5
        case"fish-family":
            return 1.5
        case "steps-guide":
            return 1.5
        case "task-rewards":
            return 2.0
        default:
            return 1.3
        }
    }
    
    var body: some View {
        VStack(spacing: 20) { // Increased spacing
            // Animation
            LottieView(fileName: page.animationName, loopMode: .loop, play: true)
                .frame(height: 200)
                .scaleEffect(animationScale)
            
            Spacer().frame(height: 80) // Reduced spacing
            
            // Title with gradient
            Text(page.title)
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .bold()
            
            // Subtitle with glow
            Text(page.subtitle)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.blue)
                .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 0)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Description with better formatting
            // Description with better formatting
            Text(page.description)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineSpacing(8) // Added line spacing
                .padding(.horizontal, 40)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.3))
                        .shadow(color: .white.opacity(0.1), radius: 5, x: 0, y: 0)
                )
                .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
                .frame(maxWidth: 300) // Set a maximum width for better readability
        }
        .padding(.vertical, 30)
    }
}
