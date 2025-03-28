import Combine
import SwiftUI

class TaskCompletionManager: ObservableObject {
    // MARK: - Published Properties
    @Published var completedTasks: [UserStats.CompletedTask] = []
    @Published var totalTimeSpent: [String: Int] = [:] // Tracks total time per tag
    @Published var shellCount: Int = 0 // User shell count
    @Published var fishDeathCount: [String: Int] = [:] // Tracks the number of times each fish has died
    @Published var unavailableFishes: [String] = [] // Fishes that are unavailable due to death
    @Published var tasksToRegainFish: [String: Int] = [:] // Tracks tasks needed to regain unavailable fishes
    @Published var unlockedFishCount: Int = 2 // Start with 2 unlocked fishes
    @Published var fishUnlockProgress: Int = 0 // Tracks task completion progress for unlocking a new fish
    @Published var userPoints: Int = 0 // Centralized points tracking
    
    // MARK: - Private Properties
    private var lastKnownPoints: Int = 0 // Ensures stability of point updates
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Initialization
    init() {
        loadSavedData()
    }
    
    // MARK: - Task Management
    func addCompletedTask(name: String, duration: Int, hasGivenUp: Bool) {
        let task = UserStats.CompletedTask(name: name, duration: duration, hasGivenUp: hasGivenUp)
        completedTasks.append(task)
        
        if hasGivenUp {
            updatePoints(onSuccess: false) // Deduct points for task failure
            handleTaskFailure(fishName: name)
        } else {
            totalTimeSpent[name, default: 0] += duration
            updatePoints(onSuccess: true) // Add points for task completion
            incrementFishUnlockProgress() // Update fish unlock progress
            reduceTaskToRegainFish() // Check and regain unavailable fishes if criteria are met
        }
        
        saveData()
    }
    
    // MARK: - Points Management
    func updatePoints(onSuccess: Bool) {
        let pointsChange = onSuccess ? 10 : -2
        let updatedPoints = max(0, lastKnownPoints + pointsChange)
        lastKnownPoints = updatedPoints
        userPoints = updatedPoints
        
        // Update shell count based on points
        updateShellCount()
        saveData()
    }
    
    func syncPoints() {
        lastKnownPoints = userPoints
        saveData()
    }
    
    private func updateShellCount() {
        shellCount = userPoints / 100 // Convert points to shells (example ratio)
    }
    
    // MARK: - Fish Management
    private func incrementFishUnlockProgress() {
        fishUnlockProgress += 1
        if fishUnlockProgress >= 3 {
            fishUnlockProgress = 0
            unlockNextFish()
        }
        saveData()
    }
    
    private func unlockNextFish() {
        if unlockedFishCount < 7 { // Maximum 7 fishes
            unlockedFishCount += 1
            saveData()
        }
    }
    
    private func handleTaskFailure(fishName: String) {
        fishDeathCount[fishName, default: 0] += 1
        
        if fishDeathCount[fishName, default: 0] >= 3 {
            unavailableFishes.append(fishName)
            tasksToRegainFish[fishName] = 5 // Need 5 successful tasks to regain
        }
        saveData()
    }
    
    func reduceTaskToRegainFish() {
        for fish in tasksToRegainFish.keys {
            tasksToRegainFish[fish, default: 0] -= 1
            if tasksToRegainFish[fish, default: 0] <= 0 {
                tasksToRegainFish[fish] = nil
                unavailableFishes.removeAll { $0 == fish }
                fishDeathCount[fish] = 0
            }
        }
        saveData()
    }
    
    // MARK: - Fish Availability
    func isFishAvailable(_ fishName: String) -> Bool {
        return !unavailableFishes.contains(fishName)
    }
    
    func getFishList(with allFishes: [String: String]) -> [String: String] {
        var fishList = allFishes
        for fish in unavailableFishes {
            fishList[fish] = "dead_fish"
        }
        return fishList
    }
    
    // MARK: - Data Persistence
     func saveData() {
        let userData = UserStats(
            totalTimeSpent: totalTimeSpent,
            completedTasks: completedTasks,
            fishUnlockProgress: fishUnlockProgress,
            unlockedFishCount: unlockedFishCount
        )
        
        if let encoded = try? JSONEncoder().encode(userData) {
            userDefaults.set(encoded, forKey: "userData")
        }
        
        userDefaults.set(userPoints, forKey: "userPoints")
        userDefaults.set(shellCount, forKey: "shellCount")
        userDefaults.set(fishDeathCount, forKey: "fishDeathCount")
        userDefaults.set(unavailableFishes, forKey: "unavailableFishes")
        userDefaults.set(tasksToRegainFish, forKey: "tasksToRegainFish")
    }
    
    private func loadSavedData() {
        if let savedData = userDefaults.data(forKey: "userData"),
           let userData = try? JSONDecoder().decode(UserStats.self, from: savedData) {
            totalTimeSpent = userData.totalTimeSpent
            completedTasks = userData.completedTasks
            fishUnlockProgress = userData.fishUnlockProgress
            unlockedFishCount = userData.unlockedFishCount
        }
        
        userPoints = userDefaults.integer(forKey: "userPoints")
        shellCount = userDefaults.integer(forKey: "shellCount")
        fishDeathCount = userDefaults.dictionary(forKey: "fishDeathCount") as? [String: Int] ?? [:]
        unavailableFishes = userDefaults.stringArray(forKey: "unavailableFishes") ?? []
        tasksToRegainFish = userDefaults.dictionary(forKey: "tasksToRegainFish") as? [String: Int] ?? [:]
        
        lastKnownPoints = userPoints
    }
    
    // MARK: - Reset Functionality
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
        
        // Clear saved data
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        saveData()
    }
}
