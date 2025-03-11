import SwiftUI
import Combine

class TimerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var timeRemaining: Int
    @Published var showingGiveUpAlert = false
    @Published var hasGivenUp = false
    @Published var progress: CGFloat = 1.0
    @Published var showingResultScreen = false
    @Published var fishAnimationOffset: CGFloat = 0
    @Published var fishSizeMultiplier: CGFloat = 1.0
    @Published var isDeadFishVisible = false
    @Published var deadFishOffset: CGSize = .zero
    @Published var waveLevel: Double = 1.0
    @Published var backgroundTimestamp: String? = nil
    @Published var timeInBackground: String? = nil
    @Published var backgroundCount: Int = 0
    
    // MARK: - Properties
    let timerValue: Int
    private var timer: Timer?
    private let taskCompletionManager: TaskCompletionManager
    private let onTaskComplete: () -> Void
    private let onTaskFail: () -> Void
    
    // MARK: - Initialization
    init(timerValue: Int, 
         taskCompletionManager: TaskCompletionManager,
         onTaskComplete: @escaping () -> Void,
         onTaskFail: @escaping () -> Void) {
        self.timerValue = timerValue
        self.timeRemaining = timerValue * 60
        self.taskCompletionManager = taskCompletionManager
        self.onTaskComplete = onTaskComplete
        self.onTaskFail = onTaskFail
    }
    
    // MARK: - Timer Methods
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            progress = CGFloat(timeRemaining) / CGFloat(timerValue * 60)
            waveLevel = Double(timeRemaining) / Double(timerValue * 60)
        } else {
            timer?.invalidate()
            completeTask()
        }
    }
    
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
        isDeadFishVisible = true
        showingResultScreen = true
    }
    
    // MARK: - Animation Methods
    func startFishAnimation() {
        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: true)) {
            fishAnimationOffset = -25
        }
    }
    
    func dropDeadFish() {
        withAnimation(Animation.easeIn(duration: 3)) {
            deadFishOffset = CGSize(width: 0, height: 150)
        }
    }
    
    // MARK: - Background State
    func handleBackgroundState() {
        backgroundTimestamp = formatTime(timeRemaining)
        timeInBackground = currentTimestamp()
        backgroundCount += 1
    }
}