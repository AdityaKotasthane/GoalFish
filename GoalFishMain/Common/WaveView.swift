//
//  WaveView.swift
//  GoalFishMain
//
//  Created by Arjun Pratap Choudhary on 04/02/25.
//


import SwiftUI

struct WaveView: View {
    @State private var waveOffset = Angle(degrees: 0)
    let progress: Double
    
    // Define lighter water gradient colors
    private let waterGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(hex: "#A5D8FF").opacity(0.7),  // Very light blue top
            Color(hex: "#7AC1FF").opacity(0.8),  // Light blue middle
            Color(hex: "#4FA8FF").opacity(0.9)   // Medium blue bottom
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Enhanced shimmer effect for lighter water
    private let shimmerGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.white.opacity(0.4),
            Color.white.opacity(0.2),
            Color.white.opacity(0.1)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Outer Glassy Circle
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.9),
                                Color(hex: "#90CAF9").opacity(0.3)  // Lighter blue border
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: geometry.size.width * 0.05
                    )
                    .shadow(color: Color(hex: "#90CAF9").opacity(0.3), radius: 10, x: 0, y: 5)

                // Inner Glass Effect
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#E3F2FD").opacity(0.3),
                                .clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .padding(geometry.size.width * 0.03)
                    .overlay(
                        Wave(offset: waveOffset, percent: progress)
                            .fill(waterGradient)
                            .overlay(
                                // Enhanced shimmer effect
                                Wave(offset: waveOffset, percent: progress)
                                    .fill(shimmerGradient)
                                    .blendMode(.screen)
                            )
                    )
                    .clipShape(Circle().scale(0.98))
                
                // Enhanced glass reflection
                Circle()
                    .scale(0.98)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.2),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                self.waveOffset = Angle(degrees: 360)
            }
        }
    }
}
