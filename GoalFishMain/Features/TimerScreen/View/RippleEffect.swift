//
//  RippleEffect.swift
//  GoalFishMain
//
//  Created by Arjun Pratap Choudhary on 12/02/25.
//


import SwiftUI

struct RippleEffect: View {
    let center: CGPoint
    @State private var ripples: [Ripple] = []
    
    struct Ripple: Identifiable {
        let id = UUID()
        var scale: CGFloat
        var opacity: Double
    }
    
    var body: some View {
        ZStack {
            ForEach(ripples) { ripple in
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .scaleEffect(ripple.scale)
                    .opacity(ripple.opacity)
                    .position(center)
            }
        }
        .onAppear {
            createRipple()
        }
    }
    
    private func createRipple() {
        let ripple = Ripple(scale: 0, opacity: 0.5)
        ripples.append(ripple)
        
        // Play sound when ripple is created
        SoundManager.shared.playRippleSound()
        
        withAnimation(.easeOut(duration: 2)) {
            ripples[ripples.count - 1].scale = 3
            ripples[ripples.count - 1].opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ripples.removeFirst()
        }
    }
}
