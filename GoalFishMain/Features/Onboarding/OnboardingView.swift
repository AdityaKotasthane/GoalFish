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
            title: "A Student's Journey with ADHD",
            subtitle: "From Chaos to Calm",
            description: "Hi there! I’m Arjun, and like you, I’ve faced the chaos of ADHD—time blindness, task overwhelm, you name it! But one day, while watching fish swim peacefully in an aquarium, I found something magical… their gentle movements helped me focus.",
            animationName: "adhd-thoughts"
        ),
        OnboardingPage(
            title: "The Science Behind FocusFish",
            subtitle: "Nature’s Focus Tool",
            description: "Did you know? Scientists found that watching fish reduces stress by 12% and gamification boosts focus by 20%. That’s why I created FocusFish—to bring this calming power to your everyday life. Let’s turn focus into fun!",
            animationName: "fish-family"
        ),
        OnboardingPage(
            title: "Your Path to Focused Success",
            subtitle: "Small Steps, Big Progress",
            description: "Here’s how it works:\n🐠 Pick your fish buddy\n⏱️ Set small time blocks that suit you\n🌟 Complete tasks to keep your fish happy and thriving!\n⚠️ But beware! If you give up, your fish dies, and you lose precious shells. Stay focused to keep your underwater world alive!",
            animationName: "steps-guide"
        ),
        OnboardingPage(
            title:  "Build Your Calming Underwater World",
            subtitle: "Your Underwater Sanctuary",
            description: "Every completed task helps your fish thrive and earns you shells. Use them to unlock new fish buddies or expand your underwater world. Together, we’ll create a calming space that works with your ADHD brain—not against it!",
            animationName: "rewards-shells"
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
                            .font(.appTitle(18))
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
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
            return 0.13
        case"fish-family":
            return 0.4
        case "steps-guide", "rewards-shells":
            return 1.0
        default:
            return 1.0
        }
    }
    
    var body: some View {
        VStack(spacing: 25) { // Increased spacing
            // Animation
            LottieView(animationName: page.animationName, loopMode: .loop, play: true)
                .frame(height: 200)
                .scaleEffect(animationScale)
            
            Spacer().frame(height: 50) // Reduced spacing
            
            // Title with gradient
            Text(page.title)
                .font(.appTitle(32)) // Increased size
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Subtitle with glow
            Text(page.subtitle)
                .font(.appHeading(20))
                .foregroundColor(.blue)
                .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 0)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Description with better formatting
            Text(page.description)
                .font(.appBody(16))
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
        }
        .padding(.vertical, 30)
    }
}
