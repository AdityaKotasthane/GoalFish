import SwiftUI
import Combine

// MARK: - User Model
struct User: Codable {
    var id: UUID = UUID()
    var points: Int
    var shellCount: Int
    var taskCompletionStreak: Int
    var selectedBackground: String
    var unlockedBackgrounds: [String]
    var selectedFish: String?
    var unlockedFishes: [String]
    var unavailableFishes: [String]
    var tasksToRegainFish: [String: Int]
}

// MARK: - Task Model
struct Task: Identifiable, Codable {
    let id: UUID = UUID()
    let name: String
    let duration: Int
    let category: TaskCategory
    var isCompleted: Bool
    var hasGivenUp: Bool
    let completedAt: Date?
    
    enum TaskCategory: String, Codable, CaseIterable {
        case study = "Study"
        case work = "Work"
        case meditate = "Meditate"
        case exercise = "Exercise"
        
        var color: Color {
            switch self {
            case .study: return .green
            case .work: return .blue
            case .meditate: return .orange
            case .exercise: return .purple
            }
        }
    }
}

// MARK: - Fish Model
struct Fish: Identifiable, Codable {
    let id: String
    let name: String
    let imageAsset: String
    let unlockCost: Int
    var isUnlocked: Bool
    var isAvailable: Bool
    var deathCount: Int
    var tasksToRegain: Int?
}

// MARK: - UserStats Model
struct UserStats: Codable {
    var totalTimeSpent: [String: Int]
    var completedTasks: [CompletedTask]
    var fishUnlockProgress: Int
    var unlockedFishCount: Int
    
    // Nested type for completed tasks
    struct CompletedTask: Codable {
        let name: String
        let duration: Int
        let hasGivenUp: Bool
    }
}

struct Background: Identifiable, Codable {
    let id: String
    let name: String
    let imageAsset: String
    let description: String
    let shellCost: Int
    var isUnlocked: Bool
}

struct Shop: Codable {
    var unlockedBackgrounds: Set<String>
    var selectedBackground: String
}
// MARK: - TimerState Model
struct TimerState: Codable {
    var selectedDuration: Double
    var isRunning: Bool
    var timeRemaining: Double
    var progress: Double
}
