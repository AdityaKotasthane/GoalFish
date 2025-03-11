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
               Color.black.opacity(0.8)
                   .edgesIgnoringSafeArea(.all)
               
               VStack(spacing: 10) {
                   // Header
                   HStack {
                       Text("Shop New Aquatic Worlds")
                           .font(.appTitle(25))
                           .foregroundColor(.white)
                       
                       Spacer()
                       
                       Button(action: { dismiss() }) {
                           Image(systemName: "xmark.circle.fill")
                               .font(.title)
                               .foregroundColor(.red)
                       }
                   }
                   .padding(.horizontal)
                   .padding(.top, 30)
                   
                   // Shell Counter
                   HStack {
                       Image("shell")
                           .resizable()
                           .frame(width: 30, height: 30)
                       Text("\(viewModel.userPoints)")
                           .font(.appTitle(20))
                           .foregroundColor(.white)
                   }
                   .padding(.bottom, 20) 
                   
                   // Carousel
                   TabView(selection: $currentIndex) {
                       ForEach(Array(viewModel.availableBackgrounds.enumerated()), id: \.element.id) { index, background in
                           BackgroundCard(
                               background: background,
                               isUnlocked: viewModel.isBackgroundUnlocked(background.id),
                               isSelected: viewModel.selectedBackground == background.id,
                               onPurchase: {
                                   if viewModel.unlockBackground(background) {
                                       HapticManager.shared.successFeedback()
                                   }
                               },
                               onSelect: {
                                   viewModel.selectBackground(background.id)
                                   HapticManager.shared.lightImpact()
                               },
                               viewModel: viewModel
                           )
                           .tag(index)
                       }
                   }
                   .tabViewStyle(PageTabViewStyle())
                   .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                   .frame(height: UIScreen.main.bounds.height * 0.6) // Increased height
                   .padding(.bottom, 30) // Added bottom padding
               }
               .frame(maxHeight: .infinity) // Make VStack take full height
           }
       }
   }
    
    struct BackgroundCard: View {
        let background: Background
        let isUnlocked: Bool
        let isSelected: Bool
        let onPurchase: () -> Void
        let onSelect: () -> Void
        @ObservedObject var viewModel: HomeViewModel
        @State private var showInsufficientShellsAlert = false
        
        var body: some View {
                VStack(spacing: 15) { // Added spacing
                    Image(background.imageAsset)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height * 0.4) // Increased height
                        .clipped()
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 3)
                        )
                    
                    Text(background.name)
                        .font(.appTitle(25))// Increased font size
                        .foregroundColor(.white)
                    
                    Text(background.description)
                        .font(.appCaption(14)) // Increased font size
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Button section
                    if isUnlocked {
                        Button(action: onSelect) {
                            Text(isSelected ? "Selected" : "Select")
                                .font(.appTitle(18)) // Increased font size
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 220, height: 50) // Increased button size
                                .background(isSelected ? Color.green : Color.blue)
                                .cornerRadius(10)
                        }
                    } else {
                        Button(action: {
                            if background.shellCost > viewModel.userPoints {
                                showInsufficientShellsAlert = true
                            } else {
                                onPurchase()
                            }
                        }) {
                            HStack {
                                Image("shell")
                                    .resizable()
                                    .frame(width: 25, height: 25) // Increased icon size
                                Text("\(background.shellCost)")
                                    .font(.appTitle(18))// Increased font size
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 220, height: 50) // Increased button size
                            .background(Color.orange)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.vertical, 20) // Added vertical padding
                .padding(.horizontal)
                .background(Color.black.opacity(0.5))
                .cornerRadius(20)
                .alert(isPresented: $showInsufficientShellsAlert) {
                    Alert(
                        title: Text("Not Enough Shells"),
                        message: Text("Complete more tasks to earn shells!"),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
