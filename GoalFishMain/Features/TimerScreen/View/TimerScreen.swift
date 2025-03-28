import SwiftUI

struct TimerScreen: View {
    @StateObject private var viewModel: TimerViewModel
    @Binding var selectedFish: String?
    @Binding var selectedTag: String?
    @Binding var userPoints: Int
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @AppStorage("selectedBackground") private var selectedBackground: String = "background5"
    private let taskCompletionManager: TaskCompletionManager
    @State private var backgroundTask: UIBackgroundTaskIdentifier?  // ✅ Prevent immediate suspension
    init(timerValue: Int,
         selectedFish: Binding<String?>,
         selectedTag: Binding<String?>,
         userPoints: Binding<Int>,
         taskCompletionManager: TaskCompletionManager,
         onTaskComplete: @escaping () -> Void,
         onTaskFail: @escaping () -> Void) {
        self.taskCompletionManager = taskCompletionManager
        _selectedFish = selectedFish
        _selectedTag = selectedTag
        _userPoints = userPoints
        _viewModel = StateObject(wrappedValue: TimerViewModel(
            timerValue: timerValue,
            selectedFish: selectedFish.wrappedValue,
            selectedTag: selectedTag.wrappedValue,
            taskCompletionManager: taskCompletionManager,
            onTaskComplete: onTaskComplete,
            onTaskFail: onTaskFail
        ))
    }
    
    
    @State private var ripples: [RipplePoint] = []
    
    struct RipplePoint: Identifiable {
        let id = UUID()
        let location: CGPoint
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background image
                Image(selectedBackground)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(1)
                
                // Ripple Effects Layer
                ForEach(ripples) { point in
                    RippleEffect(center: point.location)
                }
                
                VStack(spacing: 0) {
                    // Top Section with Timer
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.7))
                            .frame(width: 150, height: 60)
                        
                        Text(viewModel.formatTime(viewModel.timeRemaining))
                            .font(.custom("Supercell-Magic", size: 25))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.top, UIScreen.main.bounds.height * 0.1)
                    
                    Spacer().frame(height: 20)
                    // Motivational message
                    if !viewModel.currentMotivationalMessage.isEmpty {
                        Text(viewModel.currentMotivationalMessage)
                            .font(.appHeading(18))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(10)
                            .transition(.scale.combined(with: .opacity))
                    }
                    // Center Section with Fish Pot
                    ZStack {
                        // Progress Circle and Water
                        ZStack {
                            // Progress Circle
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                                .frame(width: 300, height: 300)

                            Circle()
                                .trim(from: 0, to: CGFloat(viewModel.timeRemaining) / CGFloat(viewModel.timerValue * 60))
                                .stroke(Color.green, lineWidth: 20)
                                .frame(width: 330, height: 330)
                                .rotationEffect(.degrees(-90))

                            // Water Wave Animation
                            WaveView(progress: 0.5)
                                .frame(width: 300, height: 300)
                                .zIndex(1)

                            // Fish with Dead Fish Animation
                            if viewModel.isDeadFishVisible {
                                Image("dead_fish")
                                    .resizable()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                                    .offset(viewModel.deadFishOffset)
                                    .zIndex(2)
                                    .onAppear { viewModel.dropDeadFish() }
                            } else if let fish = selectedFish {
                                ZStack {
                                    if viewModel.isLottieAnimated(fish) {
                                        // Show Lottie animation for Lottie-based fishes
                                        LottieView(fileName: fish, loopMode: .loop, play: true)
                                            .frame(width: 150, height: 150)
                                            .clipShape(Circle())
                                            .scaleEffect(viewModel.currentFishSize)
                                            .zIndex(2)
                                    } else {
                                        // Show static image for non-Lottie fishes
                                        Image(fish)
                                            .resizable()
                                            .frame(width: 150, height: 150)
                                            .clipShape(Circle())
                                            .scaleEffect(viewModel.currentFishSize)
                                            .zIndex(2)
                                    }
                                }
                                .offset(y: viewModel.fishAnimationOffset)
                                .onAppear { viewModel.startFishAnimation() }
                            }
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.6)
                    
                    // Add the goal display here
                    if let tag = selectedTag {
                            
                            Text(tag)
                                .font(.custom("Supercell-Magic", size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.gray.opacity(0.3))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                        
                        .padding(.top, -20) // Adjust this value to position it properly
                    }
                    
                    // Bottom Section with Give Up Button
                    VStack {
                        Button(action: { viewModel.showingGiveUpAlert = true }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.red)
                                    .frame(width: 200, height: 60)
                                    .shadow(radius: 5)
                                
                                Text("Give up")
                                    .foregroundColor(.white)
                                    .font(.custom("Supercell-Magic", size: 20))
                            }
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.2)
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        createRipple(at: value.location)
                    }
            )
            .navigationBarBackButtonHidden(true)
            .alert(isPresented: $viewModel.showingGiveUpAlert) {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("Your fish will die if you exit."),
                    primaryButton: .destructive(Text("Yes")) {
                        viewModel.hasGivenUp = true
                        viewModel.triggerFishDropAndTransition()
                    },
                    secondaryButton: .cancel()
                )
            }
            .navigationDestination(isPresented: $viewModel.showingResultScreen) {
                ResultScreen(
                    studyTime: Double(taskCompletionManager.totalTimeSpent["Study"] ?? 0),
                    workTime: Double(taskCompletionManager.totalTimeSpent["Work"] ?? 0),
                    meditateTime: Double(taskCompletionManager.totalTimeSpent["Meditate"] ?? 0),
                    exerciseTime: Double(taskCompletionManager.totalTimeSpent["Exercise"] ?? 0),
                    remainingTime: viewModel.timeRemaining,
                    isTaskCompleted: !viewModel.hasGivenUp,
                    userPoints: $userPoints,
                    selectedFish: $selectedFish, selectedTag: $selectedTag,
                    taskCompletionManager: taskCompletionManager,
                    backgroundCount: viewModel.backgroundCount,
                    timerValue: viewModel.timerValue
                )
            }
            .onAppear { viewModel.startTimer() }
            .onDisappear { viewModel.stopTimer() }
            // ✅ If the app tries to close, show the Give-Up popup instantly
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .background {
                    preventAppClosure()
                }
            }//            .onChange(of: scenePhase) { oldPase, newPhase in
//                if newPhase == .background {
//                    viewModel.handleBackgroundState()
//                }
//            }
        }
    }
    
    // ✅ Prevent app from closing immediately
    private func preventAppClosure() {
        viewModel.showingGiveUpAlert = true  // Show popup immediately

        // ✅ Prevent app suspension temporarily
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            // If the system decides to suspend the app, assume user gave up
            viewModel.hasGivenUp = true
            viewModel.triggerFishDropAndTransition()
        }
    }
    
    private func createRipple(at location: CGPoint) {
        // Only create new ripple if we're not too close to existing ones
        let minimumDistance: CGFloat = 50
        guard !ripples.contains(where: {
            hypot(location.x - $0.location.x, location.y - $0.location.y) < minimumDistance
        }) else { return }
        
        let ripple = RipplePoint(location: location)
        ripples.append(ripple)
        
        // Remove ripple after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            ripples.removeAll { $0.id == ripple.id }
        }
    }
}
