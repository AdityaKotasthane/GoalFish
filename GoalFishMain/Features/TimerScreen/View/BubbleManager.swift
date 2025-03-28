//
//  BubbleManager.swift
//  GoalFishMain
//
//  Created by Arjun Pratap Choudhary on 18/03/25.
//


import SwiftUI
import Combine

class BubbleManager: ObservableObject {
    @Published var bubbles: [Bubble] = []
    private var bounds: CGRect = .zero
    private var timer: Timer?
    private let maxBubbles = 8
    
    func start(in bounds: CGRect) {
        self.bounds = bounds
        
        // Create bubbles periodically
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.createBubbleIfNeeded()
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        bubbles.removeAll()
    }
    
    private func createBubbleIfNeeded() {
        guard bubbles.count < maxBubbles else { return }
        
        let newBubble = Bubble.random(in: bounds)
        bubbles.append(newBubble)
        
        // Animate bubble rising
        withAnimation(.linear(duration: 4 * newBubble.speed)) {
            var updatedBubble = newBubble
            updatedBubble.position.y = bounds.minY - newBubble.size
            bubbles[bubbles.count - 1] = updatedBubble
        }
        
        // Remove bubble after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + (4 * newBubble.speed)) {
            self.bubbles.removeAll { $0.id == newBubble.id }
        }
    }
}