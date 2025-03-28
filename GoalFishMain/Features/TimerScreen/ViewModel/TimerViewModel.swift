//
//  TimerViewModel.swift
//  GoalFishMain
//
//  Created by Arjun Pratap Choudhary on 04/02/25.
//

import SwiftUI
import Combine

class TimerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var timeRemaining: Int
    @Published var showingGiveUpAlert = false
    @Published var hasGivenUp = false
    @Published var showingResultScreen = false
    @Published var fishAnimationOffset: CGFloat = 0
    @Published var fishSizeMultiplier: CGFloat = 1.0
    @Published var isDeadFishVisible = false
    @Published var deadFishOffset: CGSize = .zero
    @Published var waveLevel: Double = 1.0
    @Published var backgroundTimestamp: String? = nil
    @Published var backgroundCount: Int = 0
    @Published var currentFishSize: CGFloat = 1.0
    @Published var currentMotivationalMessage: String = ""
    
    private let messages = [
        "First milestone reached! Keep going! 🐠",
        "Halfway there! You're doing great! 🌊",
        "Almost done! Stay focused! 🎯",
        "Final stretch! You've got this! 🌟"
    ]
    
    // MARK: - Properties
    let timerValue: Int
    private var timer: Timer?
    private let taskCompletionManager: TaskCompletionManager
    let selectedFish: String?
    let selectedTag: String?
    private let onTaskComplete: () -> Void
    private let onTaskFail: () -> Void
    
    // MARK: - Initialization
    init(timerValue: Int,
         selectedFish: String?,
         selectedTag: String?,
         taskCompletionManager: TaskCompletionManager,
         onTaskComplete: @escaping () -> Void,
         onTaskFail: @escaping () -> Void) {
        self.timerValue = timerValue
        self.timeRemaining = timerValue * 60
        self.selectedFish = selectedFish
        self.selectedTag = selectedTag
        self.taskCompletionManager = taskCompletionManager
        self.onTaskComplete = onTaskComplete
        self.onTaskFail = onTaskFail
    }
    
    let lottieAnimatedFishes: Set<String> = [
        "turtle2",
        "octopus",
        "turtle3"
    ]

    // Helper function to check if a fish uses Lottie animation
    func isLottieAnimated(_ fishId: String) -> Bool {
        return lottieAnimatedFishes.contains(fishId)
    }
    // MARK: - Timer Methods
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
//    private func updateTimer() {
//        if timeRemaining > 0 {
//            timeRemaining -= 1
//            waveLevel = Double(timeRemaining) / Double(timerValue * 60)
//        } else {
//            timer?.invalidate()
//            completeTask()
//        }
//    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Task Management
    func completeTask() {
        taskCompletionManager.addCompletedTask(
            name: selectedTag ?? "Unnamed Task",
            duration: timerValue,
            hasGivenUp: false
        )
        onTaskComplete()
        showingResultScreen = true
    }
    
    func failTask() {
        stopTimer()
        taskCompletionManager.addCompletedTask(
            name: selectedTag ?? "Unnamed Task",
            duration: timerValue,
            hasGivenUp: true
        )
        onTaskFail()
    }
    
    // MARK: - Animation Methods
    func startFishAnimation() {
        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: true)) {
            fishAnimationOffset = -25
        }
    }
    
    func dropDeadFish() {
        withAnimation(Animation.easeIn(duration: 3)) {
            // Adjust this value to control where the fish drops
            // Positive values move down, negative values move up
            // Try different values between 50-100 for a more natural drop position
            deadFishOffset = CGSize(width: 0, height: 75) // Changed from 150 to 75
        }
    }
    
    // MARK: - Dead Fish Feature
    func triggerFishDropAndTransition() {
        stopTimer() // Stop the timer immediately
        isDeadFishVisible = true // Show dead fish
        
        // Start the sequence of animations
        withAnimation {
            fishAnimationOffset = 0 // Reset living fish position
        }
        
        // Trigger fail task and dead fish animation
        failTask()
        dropDeadFish()
        
        // Delay navigation to result screen until after fish drop animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            self?.showingResultScreen = true
        }
    }
    
    // MARK: - Background State
    func handleBackgroundState() {
        backgroundTimestamp = formatTime(timeRemaining)
        backgroundCount += 1
    }
    
    // MARK: - Helper Methods
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func updateFishGrowth() {
            // Calculate quarter intervals based on total duration
            let totalSeconds = timerValue * 60
            let quarterDuration = totalSeconds / 4
            
            // Check if we've reached a quarter milestone
            switch timeRemaining {
            case ..<(quarterDuration):  // Last quarter
                updateSize(to: 1.75, messageIndex: 3)
            case ..<(quarterDuration * 2):  // Third quarter
                updateSize(to: 1.50, messageIndex: 2)
            case ..<(quarterDuration * 3):  // Second quarter
                updateSize(to: 1.25, messageIndex: 1)
            default:
                break
            }
        }
        
        private func updateSize(to newSize: CGFloat, messageIndex: Int) {
            // Only update if the size hasn't been increased for this threshold
            if currentFishSize < newSize {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    currentFishSize = newSize
                    currentMotivationalMessage = messages[messageIndex]
                }
                
                // Clear the message after a few seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation {
                        self.currentMotivationalMessage = ""
                    }
                }
            }
        }
        
        private func updateTimer() {
            if timeRemaining > 0 {
                timeRemaining -= 1
                waveLevel = Double(timeRemaining) / Double(timerValue * 60)
                updateFishGrowth()  // Add this line to update fish size
            } else {
                timer?.invalidate()
                completeTask()
            }
        }
}
