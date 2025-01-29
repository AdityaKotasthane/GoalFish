import SwiftUI
import GameKit
import Lottie

struct ContentView: View {
    @State private var floatingOffset: CGFloat = 0
    @State private var selectedValue: Double = 10 // Default selected value set to 10 minutes
    @State private var isTiming = false
    @State private var timeRemaining: Double = 0
    @State private var timer: Timer?
    @State private var isShowingFishSelection = false
    @State private var selectedFish: String? = nil
    @State private var isShowingTagList = false
    @State private var selectedTag: String? = nil
    @State private var isSideMenuOpen = false
    @AppStorage("userPoints") private var userPoints = 0 // Track user points
    @AppStorage("taskCompletionStreak") private var taskCompletionStreak = 0
    @AppStorage("unlockedFishCount") private var unlockedFishCount = 2 // Start with 2 unlocked fishes
    @AppStorage("selectedBackground") private var selectedBackground: String = "background3" // Default background
    
    let tagOptions = ["Study", "Work", "Meditate", "Exercise"]
    let tagColors: [Color] = [.red, .green, .blue, .orange]
    let allFishes = [
        "Fishy": "fish1",
        "Nemo": "fish2",
        "Starfish": "fish3",
        "Turtle": "fish4",
        "Squid": "fish5",
        "Bluey": "fish6",
        "Puffball": "fish7"
    ]
    
    @State private var isShowingPopup = false
    @State private var isFocusModeActive = false
    @State private var isAnimationPlaying = false
    @State private var navigateToTimerScreen = false // State-driven navigation
    @StateObject private var taskCompletionManager = TaskCompletionManager() // Initialize the task completion manager
    
    var unlockedFishes: [String: String] {
        Array(allFishes.prefix(unlockedFishCount))
            .reduce(into: [String: String]()) { $0[$1.key] = $1.value }
    }
    func handleTaskCompletion(isTaskSuccessful: Bool) {
        if isTaskSuccessful {
            taskCompletionStreak += 1
            // Unlock a new fish every 3 completed tasks (if more fishes are available)
            if taskCompletionStreak % 2 == 0, unlockedFishCount < allFishes.count {
                unlockedFishCount += 1
            }
        } else {
            // If task failed, re-lock the last unlocked fish (but never go below 2 unlocked fishes)
            if unlockedFishCount > 2 {
                unlockedFishCount -= 1
            }
            taskCompletionStreak = max(0, taskCompletionStreak - 1) // Reduce streak but not below 0
        }
    }


    
    func tagColor(for selectedTag: String) -> Color {
        if let index = tagOptions.firstIndex(of: selectedTag) {
            return tagColors[index]
        }
        return Color.white // Default color if not found
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background image
                Image(selectedBackground)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(1)
                
                VStack {
                    // Top section: points and activity selection
                    headerSection
                    
                    // Lottie Animation
                    VStack {
                        Spacer()
                        AnimatedView(fileName: "splashscreen.json")
                            .frame(width: UIScreen.main.bounds.width * 0.5, height: 5)
                            .padding(.bottom, 0)
                            .offset(y: UIScreen.main.bounds.height * 0.45)
                            .zIndex(1)
                    }
                    
                    // Timer and Fish Pot with Wave Animation
                    timerAndFishPotWithWater
                    
                    Spacer()
                    
                    // Bottom section: CircularSlider and start button
                    sliderAndStartButton
                }
                
                // Tag List Popover
                if isShowingTagList {
                    tagListPopover
                }
            }
            .navigationDestination(isPresented: $navigateToTimerScreen) {
                TimerScreen(
                    timerValue: Int(selectedValue),
                    selectedFish: $selectedFish,
                    selectedTag: $selectedTag,
                    userPoints: $userPoints,
                    taskCompletionManager: taskCompletionManager,
                    onTaskComplete: {
                        taskCompletionManager.addCompletedTask(
                            name: selectedTag ?? "Unnamed Task",
                            duration: Int(selectedValue),
                            hasGivenUp: false
                        )
                        syncPoints()
                    },
                    onTaskFail: {
                        taskCompletionManager.addCompletedTask(
                            name: selectedTag ?? "Unnamed Task",
                            duration: Int(selectedValue),
                            hasGivenUp: true
                        )
                        syncPoints()
                    }
                )
            }

            .navigationBarItems(
                leading: Button(action: {
                    isSideMenuOpen.toggle()
                }) {
                    Image("menu")
                        .resizable()
                        .frame(width: 40, height: 40)
                },
                trailing: Button(action: {
                    isShowingPopup.toggle() // Tapping opens the shell popup
                }) {
                    ZStack {
                        Image("ShellCounter")
                            .resizable()
                            .frame(width: 80, height: 50)
                        
                        Text("\(userPoints)")
                            .foregroundColor(.white)
                            .font(.custom("Supercell-Magic", size: 16))
                            .bold()
                            .offset(x: 15)
                    }
                }
            )
            .sheet(isPresented: $isShowingFishSelection) {
                FishSelectionView(
                    selectedFish: $selectedFish,
                    isShowing: $isShowingFishSelection,
                    allFishes: allFishes,
                    unlockedFishes: unlockedFishes,
                    unavailableFishes: taskCompletionManager.unavailableFishes,
                    taskCompletionStreak: taskCompletionManager.fishUnlockProgress
                )
            }

            .sheet(isPresented: $isSideMenuOpen) {
                SideMenu(taskCompletionManager: taskCompletionManager, isMenuOpen: $isSideMenuOpen)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            taskCompletionManager.syncPoints()
            syncPoints()
        }
    }
    
    func syncPoints() {
        userPoints = taskCompletionManager.userPoints // Ensure points are in sync
    }
    
    // MARK: - Navigation Function
    func navigateToTimerScreenAction() {
        navigateToTimerScreen = true // Use state-driven navigation to show TimerScreen
    }
    
   
    // MARK: - UI Components
    private var headerSection: some View {
        HStack {
            Button(action: {
                isShowingTagList.toggle()
            }) {
                Image("SelectTagsButton")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .offset(y: -5)
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Button(action: {
                    isShowingFishSelection.toggle()
                }) {
                    Image("fish1")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .zIndex(2)
                }
            }
            .zIndex(4)
            .padding()
        }
        .padding()
    }
    
    private var timerAndFishPotWithWater: some View {
        ZStack {
            ZStack {
                GlassBowlView(waveLevel: 2.0)
                
                WaterAnimationView(waveLevel: 0.1 + (selectedValue / 150))
                    .frame(width: 300, height: 300)
                    .offset(y: 20)
                    .zIndex(3)
                
                if let selectedFish = selectedFish {
                    Image(selectedFish)
                        .resizable()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .offset(y: floatingOffset)
                        .onAppear {
                            withAnimation(
                                Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
                            ) {
                                floatingOffset = -20
                            }
                        }
                }
            }
            
            CircularSlider(currentValue: $selectedValue, maxValue: 120)
                .frame(width: 350, height: 350)
                .zIndex(1)
            
            VStack {
                AnimatedView(fileName: "fisherman.json")
                    .frame(width: 180, height: 120)
                    .offset(x: 30, y: 0)
                    .zIndex(2)
                    .scaleEffect(0.4)
                
                Text("\(Int(selectedValue)) min")
                    .font(.custom("Supercell-Magic", size: 25))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.bottom, 15)
            }
            .offset(y: -300)
            
            if let selectedTag = selectedTag {
                Text(selectedTag)
                    .font(.custom("Supercell-Magic", size: 25))
                    .foregroundColor(tagColor(for: selectedTag))
                    .padding(.top, -400)
                    .zIndex(5)
            }
        }
    }
    
    private var sliderAndStartButton: some View {
        VStack {
            if selectedFish != nil {
                LottieView(fileName: "StartButton", play: true)
                    .frame(width: 200, height: 100)
                    .onTapGesture {
                        isAnimationPlaying = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            navigateToTimerScreenAction()
                        }
                    }
                    .opacity(1.0)
            } else {
                LottieView(fileName: "StartButton", play: false)
                    .frame(width: 200, height: 100)
                    .opacity(0.5)
                    .allowsHitTesting(false)
            }
        }
        .padding()
    }
    
    private var tagListPopover: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isShowingTagList = false
                }
            
            VStack(spacing: 15) {
                Text("Select a Tag")
                    .font(.custom("Supercell-Magic", size: 22))
                    .foregroundColor(.black)
                    .padding()
                
                ForEach(tagOptions.indices, id: \.self) { index in
                    Button(action: {
                        selectedTag = tagOptions[index]
                        isShowingTagList = false
                    }) {
                        Text(tagOptions[index])
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(tagColors[index])
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .frame(width: 300)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
        }
    }
}




struct GlassBowlView: View {
    var waveLevel: Double // Proportional wave height based on time selection

    var body: some View {
        ZStack {
            // Outer glass-like circle
            Circle()
                .strokeBorder(LinearGradient(
                    gradient: Gradient(colors: [.white.opacity(0.8), .blue.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                ), lineWidth: 10)
                .shadow(color: Color.blue.opacity(0.2), radius: 15, x: 0, y: 10)

            // Inner reflective circle for a glassy effect
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.1), .clear]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .padding(5)

            
        }
    }
}

struct WaterAnimationView: View {
    @State private var waveOffset = Angle(degrees: 0)
    var waveLevel: Double // Current water level in the bowl

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated water waves
                WaveView(waveHeight: 10, waveOffset: waveOffset)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.blue, .cyan.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .offset(y: geometry.size.height * (1.0 - waveLevel))
                    .clipShape(Circle())
            }
            .onAppear {
                // Infinite wave animation
                withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                    waveOffset = Angle(degrees: 360)
                }
            }
        }
        .aspectRatio(1, contentMode: .fill)
    }
}

struct WaveView: Shape {
    var waveHeight: CGFloat
    var waveOffset: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let y = height / 2 + waveHeight * sin(relativeX * 2 * .pi + CGFloat(waveOffset.radians))
            if x == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        // Closing the path to create a filled wave effect
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()

        return path
    }

    // Enable wave animation by binding height and offset
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get {
            AnimatablePair(waveHeight, CGFloat(waveOffset.degrees))
        }
        set {
            waveHeight = newValue.first
            waveOffset = Angle(degrees: Double(newValue.second))
        }
    }
}
