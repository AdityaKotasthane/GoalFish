import Combine

class TaskCompletionManager: ObservableObject {
    @Published var completedTasks: [(name: String, duration: Int, hasGivenUp: Bool)] = []
    @Published var totalTimeSpent: [String: Int] = [:] // Tracks total time per tag
    @Published var shellCount: Int = 0 // User shell count
    @Published var fishDeathCount: [String: Int] = [:] // Tracks the number of times each fish has died
    @Published var unavailableFishes: [String] = [] // Fishes that are unavailable due to death
    @Published var tasksToRegainFish: [String: Int] = [:] // Tracks tasks needed to regain unavailable fishes
    @Published var unlockedFishCount: Int = 2 // Start with 2 unlocked fishes
    @Published var fishUnlockProgress: Int = 0 // Tracks task completion progress for unlocking a new fish
    @Published var userPoints: Int = 0 // Centralized points tracking
    private var lastKnownPoints: Int = 0 // Ensures stability of point updates
    
    // MARK: - Task Management
    
    /// Adds a completed task and updates the task completion state and points
    func addCompletedTask(name: String, duration: Int, hasGivenUp: Bool) {
        let task = (name: name, duration: duration, hasGivenUp: hasGivenUp)
        completedTasks.append(task)
        
        if hasGivenUp {
            updatePoints(onSuccess: false) // Deduct points for task failure
        } else {
            totalTimeSpent[name, default: 0] += duration
            updatePoints(onSuccess: true) // Add points for task completion
            incrementFishUnlockProgress() // Update fish unlock progress
            reduceTaskToRegainFish() // Check and regain unavailable fishes if criteria are met
        }
    }
    
    // MARK: - Points Management
    
    /// Updates the user's points based on task success or failure
    /// - Parameter onSuccess: true for task completion, false for failure
    func updatePoints(onSuccess: Bool) {
        let pointsChange = onSuccess ? 10 : -2
        let updatedPoints = max(0, lastKnownPoints + pointsChange)
        print("Updating points: \(lastKnownPoints) -> \(updatedPoints), Success: \(onSuccess)") // Debug print
        lastKnownPoints = updatedPoints
        userPoints = updatedPoints
    }
    
    /// Syncs the points to ensure they stay consistent across views
    func syncPoints() {
        lastKnownPoints = userPoints
    }
    
    // MARK: - Fish Unlock Management
    
    /// Increments the progress toward unlocking a new fish and unlocks a fish every 3 tasks
    private func incrementFishUnlockProgress() {
        fishUnlockProgress += 1
        if fishUnlockProgress >= 3 {
            fishUnlockProgress = 0
            unlockNextFish()
        }
    }
    
    /// Unlocks the next fish if available
    private func unlockNextFish() {
        if unlockedFishCount < 7 { // Assuming there are 7 fishes in total
            unlockedFishCount += 1
        }
    }
    
    // MARK: - Fish Regain Management
    
    /// Reduces the task count needed to regain unavailable fishes and makes them available if criteria are met
    func reduceTaskToRegainFish() {
        for fish in tasksToRegainFish.keys {
            tasksToRegainFish[fish, default: 0] -= 1
            if tasksToRegainFish[fish, default: 0] <= 0 {
                tasksToRegainFish[fish] = nil // Remove from the regain list
                unavailableFishes.removeAll { $0 == fish } // Make the fish available again
                fishDeathCount[fish] = 0 // Reset death count
            }
        }
    }
    
    // MARK: - Utility Functions
    
    /// Checks if a fish is available
    /// - Parameter fishName: The name of the fish to check
    /// - Returns: true if the fish is available, false otherwise
    func isFishAvailable(_ fishName: String) -> Bool {
        return !unavailableFishes.contains(fishName)
    }
    
    /// Returns a list of all fishes with substitutions for unavailable fishes
    /// - Parameter allFishes: Dictionary of all fishes
    /// - Returns: Modified fish list with "dead_fish" substituted for unavailable fishes
    func getFishList(with allFishes: [String: String]) -> [String: String] {
        var fishList = allFishes
        for fish in unavailableFishes {
            fishList[fish] = "dead_fish" // Replace unavailable fish with "dead fish" image
        }
        return fishList
    }
    
    // MARK: - Reset Functionality
    
    /// Resets all tracked data (optional use)
    func reset() {
        completedTasks.removeAll()
        totalTimeSpent.removeAll()
        shellCount = 0
        fishDeathCount.removeAll()
        unavailableFishes.removeAll()
        tasksToRegainFish.removeAll()
        unlockedFishCount = 2
        fishUnlockProgress = 0
        userPoints = 0
        lastKnownPoints = 0
    }
}
