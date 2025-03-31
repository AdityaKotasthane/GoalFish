//
//  ShopView.swift
//  FocusFish
//
//  Created by Arjun Pratap Choudhary on 23/02/25.
//

import SwiftUI

struct ShopView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: HomeViewModel
    @State private var currentIndex = 0
    @State private var showInsufficientShellsAlert = false
    @State private var showSparkles = false
    
    var body: some View {
        ZStack {
            // Background with blur and gradient overlay
            if let currentBackground = viewModel.availableBackgrounds.indices.contains(currentIndex) ? viewModel.availableBackgrounds[currentIndex] : nil {
                Image(currentBackground.imageAsset)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .blur(radius: 5)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]),
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            }
            
            VStack(spacing: 15) {
                // Header Section
                VStack(spacing: 8) {
                    Text("Shop New")
                        .font(.custom("Supercell-Magic", size: 26))
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                    
                    Text("Aquatic Worlds")
                        .font(.custom("Supercell-Magic", size: 22))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(radius: 3)
                    
                    // Shell Counter
                    HStack(spacing: 8) {
                        Image("shell emoji")
                            .resizable()
                            .frame(width: 28, height: 28)
                        Text("\(viewModel.userPoints)")
                            .font(.custom("Supercell-Magic", size: 22))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 18)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .padding(.top, 25)
                
                // Carousel View
                TabView(selection: $currentIndex) {
                    ForEach(Array(viewModel.availableBackgrounds.enumerated()), id: \.element.id) { index, background in
                        BackgroundCard(
                            background: background,
                            isUnlocked: viewModel.isBackgroundUnlocked(background.id),
                            isSelected: viewModel.selectedBackground == background.id,
                            onPurchase: {
                                if viewModel.unlockBackground(background) {
                                    HapticManager.shared.successFeedback()
                                    withAnimation {
                                        showSparkles = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            showSparkles = false
                                        }
                                    }
                                }
                            },
                            onSelect: {
                                viewModel.selectBackground(background.id)
                                HapticManager.shared.lightImpact()
                                withAnimation {
                                    showSparkles = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        showSparkles = false
                                    }
                                }
                            },
                            viewModel: viewModel,
                            showSparkles: $showSparkles
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
//                .padding(.top, 10)
                .padding(.bottom, 40)
            }
//            .padding(.bottom, 20) // Account for tab bar
            
            if showSparkles {
                LottieView(fileName: "sparkles", play: true)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
//                    .scaleEffect(1.5)
            }
            
        }
    }
}


// BackgroundCard View
struct BackgroundCard: View {
    let background: Background
    let isUnlocked: Bool
    let isSelected: Bool
    let onPurchase: () -> Void
    let onSelect: () -> Void
    @ObservedObject var viewModel: HomeViewModel
    @Binding var showSparkles: Bool
    @State private var showInsufficientShellsAlert = false
    
    var body: some View {
        VStack(spacing: 18) {
            // Background Preview
            ZStack {
                Image(background.imageAsset)
                    .resizable()
                    .aspectRatio(1/1, contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width * 0.85)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                
                
                // Status Badge
                if !isUnlocked {
                    LockBadgeView()
                } else if isSelected {
                    SelectedBadgeView()
                }
            }
            
            // Title & Description
            VStack(spacing: 6) {
                Text(background.name)
                    .font(.custom("Supercell-Magic", size: 22))
                    .foregroundColor(.white)
                    .shadow(radius: 3)
                
                Text(background.description)
                    .font(.custom("Supercell-Magic", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .frame(width: UIScreen.main.bounds.width * 0.85)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.6))
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 10)
                    )
            }
            
            // Action Button
            Button(action: isUnlocked ? onSelect : {
                if background.shellCost > viewModel.userPoints {
                    showInsufficientShellsAlert = true
                } else {
                    onPurchase()
                }
            }) {
                HStack(spacing: 10) {
                    if !isUnlocked {
                        Image("shell emoji")
                            .resizable()
                            .frame(width: 25, height: 25)
                    }
                    Text(isUnlocked ? (isSelected ? "Current" : "Select") : "\(background.shellCost)")
                        .font(.custom("Supercell-Magic", size: 18))
                }
                .foregroundColor(.white)
                .frame(width: 210, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    isUnlocked ?
                                        (isSelected ? Color(hex: "#4A90E2").opacity(0.9) : Color(hex: "#64B5F6").opacity(0.8)) :
                                        Color(hex: background.id == "background3" ? "#FF9800" :
                                             background.id == "background1" ? "#FFA726" : "#FB8C00").opacity(0.9),
                                    isUnlocked ?
                                        (isSelected ? Color(hex: "#1976D2") : Color(hex: "#2196F3").opacity(0.9)) :
                                        Color(hex: background.id == "background3" ? "#F57C00" :
                                             background.id == "background1" ? "#FB8C00" : "#EF6C00")
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: isUnlocked ?
                        (isSelected ? Color(hex: "#1976D2").opacity(0.6) : Color(hex: "#2196F3").opacity(0.5)) :
                        Color(hex: background.id == "background3" ? "#F57C00" :
                             background.id == "background1" ? "#FB8C00" : "#EF6C00").opacity(0.6),
                        radius: 10, x: 0, y: 5)
            }
            .alert(isPresented: $showInsufficientShellsAlert) {
                Alert(
                    title: Text("Not Enough Shells"),
                    message: Text("Complete more focus sessions to earn shells!"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal)
    }
}

// Helper Views for Badges
struct LockBadgeView: View {
    var body: some View {
        Image(systemName: "lock.fill")
            .font(.system(size: 40))
            .foregroundColor(.white)
            .padding(12)
            .background(Circle().fill(Color.black.opacity(0.7)))
    }
}

struct SelectedBadgeView: View {
    var body: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(.white)
            .padding(12)
            .background(Circle().fill(Color.green))
    }
}
