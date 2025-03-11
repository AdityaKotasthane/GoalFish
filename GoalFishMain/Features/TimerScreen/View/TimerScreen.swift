import SwiftUI
import Lottie

struct TimerScreen: View {
    let timerValue: Int
    @State private var timeRemaining: Int
    @State private var timer: Timer?
    @Binding var selectedFish: String?
    @Binding var selectedTag: String?
    @Binding var userPoints: Int
    @ObservedObject var taskCompletionManager: TaskCompletionManager
    let onTaskComplete: () -> Void // Callback for task completion
    let onTaskFail: () -> Void // Callback for task failure
    @State private var showingGiveUpAlert = false
    @State private var hasGivenUp = false
    @State private var progress: CGFloat = 1.0
    @Environment(\.scenePhase) private var scenePhase
    @State private var showingResultScreen = false
    @State private var fishAnimationOffset: CGFloat = 0
    @State private var fishSizeMultiplier: CGFloat = 1.0
    @State private var isDeadFishVisible = false
    @State private var deadFishOffset: CGSize = .zero
    @AppStorage("selectedBackground") private var selectedBackground: String = "background1" // Sync background selection
    @State private var waveLevel: Double = 1.0
    @State private var backgroundTimestamp: String? = nil
    @State private var timeInBackground: String? = nil
    @State private var backgroundCount: Int = 0

    init(timerValue: Int, selectedFish: Binding<String?>, selectedTag: Binding<String?>, userPoints: Binding<Int>, taskCompletionManager: TaskCompletionManager, onTaskComplete: @escaping () -> Void, onTaskFail: @escaping () -> Void) {
        self.timerValue = timerValue
        _timeRemaining = State(initialValue: timerValue * 60)
        _selectedFish = selectedFish
        _selectedTag = selectedTag
        _userPoints = userPoints
        self.taskCompletionManager = taskCompletionManager
        self.onTaskComplete = onTaskComplete
        self.onTaskFail = onTaskFail
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Image (Using @AppStorage)
                Image(selectedBackground)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Timer Display
                    Text(formatTime(timeRemaining))
                        .font(.custom("Supercell-Magic", size: 25))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.top, 50)

                    if let timestamp = backgroundTimestamp {
                        Text("App went to background at: \(timestamp)")
                            .font(.custom("Supercell-Magic", size: 15))
                            .foregroundColor(.blue)
                            .padding(.top, 10)
                    }

                    Text("Background Count: \(backgroundCount)")
                        .font(.custom("Supercell-Magic", size: 15))
                        .foregroundColor(.red)
                        .padding(.top, 5)

                    Spacer()

                    // Fish Bowl and Progress
                    ZStack {
                        GlassBowlView(waveLevel: 1.0)
                            .frame(width: 300, height: 300)
                            .offset(y: 20)

//                        WaterAnimationView(waveLevel: waveLevel)
//                            .frame(width: 300, height: 300)
//                            .offset(y: 20)
//                            .zIndex(4)

                        if isDeadFishVisible {
                            Image("dead_fish")
                                .resizable()
                                .frame(width: 100 * fishSizeMultiplier, height: 100 * fishSizeMultiplier)
                                .clipShape(Circle())
                                .offset(deadFishOffset)
                                .zIndex(3)
                                .onAppear {
                                    dropDeadFish()
                                }
                        } else if let selectedFish = selectedFish {
                            Image(selectedFish)
                                .resizable()
                                .frame(width: 100 * fishSizeMultiplier, height: 100 * fishSizeMultiplier)
                                .clipShape(Circle())
                                .offset(y: 20 + fishAnimationOffset)
                                .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: fishAnimationOffset)
                                .onAppear {
                                    startFishAnimation()
                                }
                        }

                        CircularProgressBar(
                            progress: CGFloat(timeRemaining) / CGFloat(timerValue * 60),
                            lineWidth: 16,
                            color: .green
                        )
                        .frame(width: 350, height: 310)
                        .zIndex(2)
                    }

                    Spacer()

                    // Give Up Button
                    Button(action: {
                        showingGiveUpAlert = true
                    }) {
                        Text("Give up")
                            .foregroundColor(.white)
                            .font(.custom("Supercell-Magic", size: 17))
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                            .zIndex(4)
                    }
                    .padding(.bottom, 30)
                    .alert(isPresented: $showingGiveUpAlert) {
                        Alert(
                            title: Text("Are you sure?"),
                            message: Text("Your fish will die if you exit."),
                            primaryButton: .destructive(Text("Yes")) {
                                hasGivenUp = true
                                failTask()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                .padding(.top, 100)
                .onAppear {
                    if !showingResultScreen {
                        timeRemaining = timerValue * 60
                        startTimer()
                    }
                }
                .onDisappear {
                    timer?.invalidate()
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .background {
                        backgroundTimestamp = formatTime(timeRemaining)
                        timeInBackground = currentTimestamp()
                        backgroundCount += 1
                    }
                }
            }
            .navigationDestination(isPresented: $showingResultScreen) {
                ResultScreen(
                    studyTime: Double(taskCompletionManager.totalTimeSpent["Study"] ?? 0),
                    workTime: Double(taskCompletionManager.totalTimeSpent["Work"] ?? 0),
                    meditateTime: Double(taskCompletionManager.totalTimeSpent["Meditate"] ?? 0),
                    exerciseTime: Double(taskCompletionManager.totalTimeSpent["Exercise"] ?? 0),
                    remainingTime: calculateRemainingTime(),
                    isTaskCompleted: !hasGivenUp,
                    userPoints: $userPoints,
                    selectedFish: $selectedFish,
                    taskCompletionManager: taskCompletionManager,
                    backgroundCount: backgroundCount,
                    timerValue: timerValue
                )
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                progress = CGFloat(timeRemaining) / CGFloat(timerValue * 60)
                waveLevel = Double(timeRemaining) / Double(timerValue * 60)
            } else {
                timer?.invalidate()
                completeTask()
            }
        }
    }

    private func completeTask() {
        taskCompletionManager.addCompletedTask(
            name: selectedTag ?? "Unnamed Task",
            duration: timerValue,
            hasGivenUp: false
        )
        onTaskComplete() // Trigger success callback
        navigateToResultScreen()
    }

    private func failTask() {
        timer?.invalidate() // Stop the timer immediately
        timer = nil // Clear timer reference

        // Reduce streak & possibly re-lock the last unlocked fish
        taskCompletionManager.addCompletedTask(
            name: selectedTag ?? "Unnamed Task",
            duration: timerValue,
            hasGivenUp: true
        )

        onTaskFail() // Trigger failure callback
        
        syncPoints()// Sync user points after task failure
       

        // Trigger fish drop animation & transition to result screen
        triggerFishDropAndTransition()
    }



    private func syncPoints() {
        userPoints = taskCompletionManager.userPoints
    }

    private func startFishAnimation() {
        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: true)) {
            fishAnimationOffset = -25
        }
    }

    private func dropDeadFish() {
        withAnimation(Animation.easeIn(duration: 3)) {
            deadFishOffset = CGSize(width: 0, height: 150) // Drop fish to the bottom of the pot
        }
    }

    private func triggerFishDropAndTransition() {
        isDeadFishVisible = true
        dropDeadFish()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            navigateToResultScreen()
        }
    }

    private func navigateToResultScreen() {
        showingResultScreen = true
    }

    private func calculateRemainingTime() -> Int {
        return max(timeRemaining, 0)
    }

    private func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func currentTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm:ss a"
        return formatter.string(from: Date())
    }
}
