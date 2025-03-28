//
//  FishShopView.swift
//  GoalFishMain
//
//  Created by Arjun Pratap Choudhary on 13/02/25.
//


import SwiftUI

struct FishShopView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedBackground") private var selectedBackground: String = "background5"
    @Binding var userPoints: Int
    let viewModel: HomeViewModel   // Change to use ViewModel
    @State private var showPurchaseAlert = false
    @State private var selectedFishToPurchase: (name: String, image: String)?
    @State private var showInsufficientFundsAlert = false
    let allFishes: [String: String]
    let unlockedFishes: [String: String]
    
    // Fish prices
    let fishPrices: [String: Int] = [
        "fish1": 0,      // Starter fish (free)
        "fish2": 100,    // Common
        "fish3": 20,    // Uncommon
        "fish4": 350,    // Rare
        "fish5": 50,    // Epic
        "fish6": 75,    // Legendary
        "fish7": 100,    // Mythical
        "turtle2": 10,
        "octopus": 20// New Dancing Turtle
    ]
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack {
            // Background with overlay gradient for better contrast
            Image(selectedBackground)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.4),
                            Color.black.opacity(0.2)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            VStack(spacing: 0) {
                // Enhanced Header
                VStack(spacing: 15) {
                    HStack {
                        Text("Your Aquarium")
                            .font(.custom("Supercell-Magic", size: 24))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)
                        
                        Spacer()
                        
                        // Enhanced Shell Counter
                        HStack(spacing: 5) {
                            Image("ShellCounter")
                                .resizable()
                                .frame(width: 120, height: 60)
                                .overlay(
                                    Text("\(userPoints)")
                                        .foregroundColor(.white)
                                        .font(.custom("Supercell-Magic", size: 20))
                                        .shadow(color: .black.opacity(0.5), radius: 2)
                                        .offset(x: 15)
                                )
                        }
                        .scaleEffect(0.8)
                    }
                    
                    // Add a decorative divider
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.clear, .white.opacity(0.3), .clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(height: 1)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Enhanced Grid Layout
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 15),
                            GridItem(.flexible(), spacing: 15)
                        ],
                        spacing: 20
                    ) {
                        ForEach(Array(viewModel.allFishes.sorted(by: { $0.key < $1.key })), id: \.key) { fishName, fishImage in
                            FishShopItem(
                                fishName: fishName,
                                fishImage: fishImage,
                                price: fishPrices[fishImage] ?? 100,
                                isOwned: viewModel.isUnlocked(fishImage),
                                canAfford: userPoints >= (fishPrices[fishImage] ?? 100),
                                action: {
                                    if userPoints >= (fishPrices[fishImage] ?? 100) {
                                        selectedFishToPurchase = (fishName, fishImage)
                                        showPurchaseAlert = true
                                    } else {
                                        showInsufficientFundsAlert = true
                                    }
                                },
                                viewModel: viewModel
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 10)
                    .padding(.bottom, 80) // Add padding for tab bar
                }
            }
        }
        .alert("Purchase Fish", isPresented: $showPurchaseAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Buy") {
                if let fish = selectedFishToPurchase {
                    let price = fishPrices[fish.image] ?? 100
                    if viewModel.unlockFish(fishId: fish.image, price: price) {
                        // Show success animation or feedback
                        playPurchaseAnimation(fishName: fish.name)
                    }
                }
            }
        } message: {
            if let fish = selectedFishToPurchase,
               let price = fishPrices[fish.image] {
                Text("Would you like to buy \(fish.name) for \(price) shells?")
            }
        }
        .alert("Insufficient Shells", isPresented: $showInsufficientFundsAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You don't have enough shells to purchase this fish!")
        }
    }
    
    private func playPurchaseAnimation(fishName: String) {
        // Add purchase success animation here
        // You can use a Lottie animation for celebration
    }
}

// Enhanced FishShopItem
struct FishShopItem: View {
    let fishName: String
    let fishImage: String
    let price: Int
    let isOwned: Bool
    let canAfford: Bool
    let action: () -> Void
    let viewModel: HomeViewModel  // Add this line to access isLottieAnimated
    
    var body: some View {
        Button(action: isOwned ? {} : action) {
            VStack(spacing: 12) {
                // Fish Image Container
                ZStack {
                    // Glowing background for owned items
                    if isOwned {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 110, height: 110)
                            .blur(radius: 5)
                    }
                    
                    // Fish Image/Animation
                    if viewModel.isLottieAnimated(fishImage) {
                        LottieView(
                            fileName: fishImage,
                            loopMode: .loop,
                            play: true
                        )
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    } else {
                        Image(fishImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    }
                    
                    // Enhanced border
                    Circle()
                        .stroke(
                            isOwned ? Color.green : (canAfford ? Color.blue : Color.red),
                            lineWidth: 3
                        )
                        .frame(width: 100, height: 100)
                    
                    // Lock overlay with improved visibility
                    if !isOwned {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.4))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "lock.fill")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 2)
                        }
                    }
                }
                
                // Fish Name with enhanced styling
                Text(fishName)
                    .font(.custom("Supercell-Magic", size: 16))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                // Price/Status indicator
                if !isOwned {
                    HStack(spacing: 5) {
                        Image("shell emoji")
                            .resizable()
                            .frame(width: 25, height: 25)
                        
                        Text("\(price)")
                            .font(.custom("Supercell-Magic", size: 16))
                            .foregroundColor(canAfford ? .white : .red)
                            .shadow(color: .black.opacity(0.5), radius: 2)
                    }
                } else {
                    Text("Owned")
                        .font(.custom("Supercell-Magic", size: 14))
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.2))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.green.opacity(0.5), lineWidth: 1)
                                )
                        )
                }
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isOwned ? Color.green.opacity(0.3) : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 5)
        }
        .disabled(isOwned)
        .scaleEffect(isOwned ? 0.95 : 1.0)
    }
}
