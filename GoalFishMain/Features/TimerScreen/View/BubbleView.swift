//
//  BubbleView.swift
//  GoalFishMain
//
//  Created by Arjun Pratap Choudhary on 18/03/25.
//


import SwiftUI

struct BubbleView: View {
    let bubble: Bubble
    @State private var isBursting = false
    
    var body: some View {
        Circle()
            .fill(Color.white.opacity(bubble.opacity))
            .frame(width: bubble.size, height: bubble.size)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .scaleEffect(isBursting ? 1.5 : 1.0)
            .opacity(isBursting ? 0 : 1)
            .blur(radius: isBursting ? 5 : 0)
    }
    
    func burst() {
        withAnimation(.easeOut(duration: 0.3)) {
            isBursting = true
        }
    }
}