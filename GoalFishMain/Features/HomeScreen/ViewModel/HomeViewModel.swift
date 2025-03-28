import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedValue: Double = 10
    @Published var floatingOffset: CGFloat = 0
    @Published var selectedFish: String?
    @Published var selectedTag: String? {
        didSet {
            // Optional: Add any additional logic when tag changes
            objectWillChange.send()
        }
    }
    @Published var isShowingFishSelection = false
//    @Published var isShowingTagList = false
    @Published var isSideMenuOpen = false
    @Published var userPoints: Int = 0
    @Published var isShowingPopup = false
    @Published var isFocusModeActive = false
    @Published var isAnimationPlaying = false
    @Published var navigateToTimerScreen = false
    
    // Add a set to track unlocked fish IDs
     @AppStorage("unlockedFishIds") private var unlockedFishIds: String = "fish1" // Default fish
    @AppStorage("isOnboardingComplete") var isOnboardingComplete: Bool = false
    
    @AppStorage("unlockedBackgrounds") private var unlockedBackgroundIds: String = "background1,background2,background5"
    @AppStorage("selectedBackground")  var selectedBackground: String = "background5"
    
    // Add these properties
    @Published var fishDropOffset: CGFloat = -200 // Start position above the pot
    @Published var showSplashAnimation: Bool = false
    @Published var fishDropCompleted: Bool = false
   
    @Published var isShowingShop = false
    
    // MARK: - Constants
    let tagOptions = ["Focus", "Study", "Work", "Meditate", "Exercise"]
    let tagColors: [Color] = [.red, .green, .blue, .orange]
    let allFishes: [String: String] = [
        "Fishy": "fish1",
        "Nemo": "fish2",
        "Starfish": "fish3",
        "Turtle": "fish4",
        "Squid": "fish5",
        "Bluey": "fish6",
        "Puffball": "fish7",
        "Turtango": "turtle2",
        "Octopus": "octopus",  // New Lottie animation
        "Turtley": "turtle3"     // New Lottie animation
    ]

    let availableBackgrounds: [Background] = [
        Background(id: "background1", name: "Coral Haven", imageAsset: "background1",
                   description: "A vibrant coral reef bursting with color and marine life.",
                   shellCost: 0, isUnlocked: true),

        Background(id: "background2", name: "Abyssal Depths", imageAsset: "background2",
                   description: "Descend into the dark and mysterious depths of the ocean, where sunlight fades into the unknown.",
                   shellCost: 100, isUnlocked: false),

        Background(id: "background3", name: "Sunlit Lagoon", imageAsset: "background3",
                   description: "A tropical paradise with crystal-clear waters and sun rays shimmering through the sea.",
                   shellCost: 200, isUnlocked: false),

        Background(id: "background4", name: "Frozen Tides", imageAsset: "background4",
                   description: "An arctic wonderland beneath icy waters, where the cold sea meets surreal marine beauty.",
                   shellCost: 300, isUnlocked: false),

        Background(id: "background5", name: "Molten Abyss", imageAsset: "background5",
                   description: "An eerie underwater landscape filled with glowing volcanic vents and deep-sea mysteries.",
                   shellCost: 400, isUnlocked: false)
    ]
    // Add a set to identify which fish use Lottie animations
    let lottieAnimatedFishes: Set<String> = [
        "turtle2",
        "octopus",
        "turtle3"
    ]

    func isBackgroundUnlocked(_ backgroundId: String) -> Bool {
        Set(unlockedBackgroundIds.components(separatedBy: ",")).contains(backgroundId)
    }
    
    @MainActor func unlockBackground(_ background: Background) -> Bool {
        guard !isBackgroundUnlocked(background.id) else { return false }
        
        if userPoints >= background.shellCost {
            userPoints -= background.shellCost
            let currentUnlocked = Set(unlockedBackgroundIds.components(separatedBy: ","))
            let newUnlocked = currentUnlocked.union([background.id])
            unlockedBackgroundIds = Array(newUnlocked).joined(separator: ",")
            
            // Update both userPoints and lastKnownPoints in TaskCompletionManager
            taskManager.userPoints = userPoints
            taskManager.syncPoints()  // This will update lastKnownPoints
            taskManager.saveData()
            
            return true
        } else {
            HapticManager.shared.errorFeedback()
            return false
        }
    }
    
    func selectBackground(_ backgroundId: String) {
        selectedBackground = backgroundId
    }
    // Helper function to check if a fish uses Lottie animation
    func isLottieAnimated(_ fishId: String) -> Bool {
        return lottieAnimatedFishes.contains(fishId)
    }
    
    // MARK: - Private Properties
    private let taskManager: TaskCompletionManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    // Update the unlockedFishes computed property
    var unlockedFishes: [String: String] {
        let unlockedIds = Set(unlockedFishIds.components(separatedBy: ","))
        return allFishes.filter { unlockedIds.contains($0.value) }
    }
    
    // Function to unlock a fish
    func unlockFish(fishId: String, price: Int) -> Bool {
        guard !isUnlocked(fishId) && userPoints >= price else { return false }
        
        userPoints -= price
        let currentUnlocked = Set(unlockedFishIds.components(separatedBy: ","))
        let newUnlocked = currentUnlocked.union([fishId])
        unlockedFishIds = Array(newUnlocked).joined(separator: ",")
        objectWillChange.send()
        return true
    }
    
    // Helper function to check if a fish is unlocked
    func isUnlocked(_ fishId: String) -> Bool {
        Set(unlockedFishIds.components(separatedBy: ",")).contains(fishId)
    }
    // MARK: - Initialization
    init(taskManager: TaskCompletionManager) {
        self.taskManager = taskManager
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        taskManager.$userPoints
            .assign(to: \.userPoints, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func tagColor(for selectedTag: String) -> Color {
        if let index = tagOptions.firstIndex(of: selectedTag) {
            return tagColors[index]
        }
        return .white
    }
    
    func navigateToTimerScreenAction() {
        navigateToTimerScreen = true
    }
    
    func syncPoints() {
        taskManager.syncPoints()
    }
    
    func handleTaskCompletion() {
        taskManager.addCompletedTask(
            name: selectedTag ?? "Unnamed Task",
            duration: Int(selectedValue),
            hasGivenUp: false
        )
        syncPoints()
    }
    
    func handleTaskFailure() {
        taskManager.addCompletedTask(
            name: selectedTag ?? "Unnamed Task",
            duration: Int(selectedValue),
            hasGivenUp: true
        )
        syncPoints()
    }
    
    // Add this method to handle fish selection animation
    func handleFishSelection(fish: String?) {
        guard let fish = fish else { return }
        selectedFish = fish
        fishDropCompleted = false
        fishDropOffset = -200
        showSplashAnimation = false
        
        // Slower drop animation
        withAnimation(.easeIn(duration: 1.5)) {
            fishDropOffset = 0
        }
        
        // Show splash and play sound later
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.showSplashAnimation = true
            // Play water splash sound when splash animation shows
            SoundManager.shared.playSound(.waterSplash)
            
            // Keep splash visible longer
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showSplashAnimation = false
                self.fishDropCompleted = true
                
                withAnimation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                ) {
                    self.floatingOffset = -20
                }
            }
        }
    }
}
