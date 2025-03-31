import SwiftUI
import GameKit
import Lottie


struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var showSelectionHint: Bool = false
    @State private var selectedTab: Int = 0
    @State private var showFishShop = false
    @StateObject private var soundManager = SoundManager.shared
    @State private var showShellMessage: Bool = false
    @State private var isSliderDragging = false

    
    @AppStorage("selectedBackground") private var selectedBackground: String = "background5"
    private let taskManager: TaskCompletionManager  // Add this line
    
    init(taskManager: TaskCompletionManager) {
        self.taskManager = taskManager
        _viewModel = StateObject(wrappedValue: HomeViewModel(taskManager: taskManager))
        // Set default tag to "Focus"
//        if viewModel.selectedTag == nil {
//            viewModel.selectedTag = "Focus"
//        }
    }
    
    var body: some View {
        if !viewModel.isOnboardingComplete {
            OnboardingView(isOnboardingComplete: $viewModel.isOnboardingComplete)
        } else {
            NavigationStack {
                ZStack(alignment: .top) {
                    // Background image
                    Image(selectedBackground)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .opacity(1)
                    
                    TabView(selection: $selectedTab) {
                        // Home Tab
                        Group {
                            VStack(spacing: 0) {
                                // Main content
                                VStack(spacing: 0) {
                                    headerSection
                                    TagPicker
                                    splashAnimation
                                    FishPotWithWater
                                    StartButton
                                }
                                .padding(.bottom, 60)
                                Spacer(minLength: 0)
                            }
                        }
                        .tag(0)
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .trailing)
                        ))
                        
                        // Aquarium Tab
                        Group {
                            FishShopView(
                                userPoints: $viewModel.userPoints,
                                viewModel: viewModel,
                                allFishes: viewModel.allFishes,
                                unlockedFishes: viewModel.unlockedFishes
                            )
                        }
                        .tag(1)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                        
                        // Shop Tab
                        Group {
                            ShopView(viewModel: viewModel)
                        }
                        .tag(2)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)

                    // Tab bar positioned at bottom
                    VStack(spacing: 0) {
                        Spacer()
                        AquaticTabBar(selectedTab: $selectedTab)
                    }
                    .ignoresSafeArea(.all, edges: .bottom)
                }
                .overlay {
                    if showShellMessage {
                        VStack {
                            Text("Complete goals to collect more shells! 🐚")
                                .font(.appBody(14))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.black.opacity(0.8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                                .offset(y: 50)
                                .transition(.scale.combined(with: .opacity))
                        }
                        .onAppear {
                            // Auto-hide the message after 3 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation(.easeOut) {
                                    showShellMessage = false
                                }
                            }
                        }
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showShellMessage)

                .navigationDestination(isPresented: $viewModel.navigateToTimerScreen) {
                    TimerScreen(
                        timerValue: Int(viewModel.selectedValue),
                        selectedFish: $viewModel.selectedFish,
                        selectedTag: $viewModel.selectedTag,
                        userPoints: $viewModel.userPoints,
                        taskCompletionManager: taskManager,
                        onTaskComplete: viewModel.handleTaskCompletion,
                        onTaskFail: viewModel.handleTaskFailure
                    )
                }
                                .sheet(isPresented: $viewModel.isShowingFishSelection) {
                                    FishSelectionView(
                                        selectedFish: $viewModel.selectedFish,
                                        isShowing: $viewModel.isShowingFishSelection,
                                        selectedTab: $selectedTab,
                                        allFishes: viewModel.allFishes,
                                        unlockedFishes: viewModel.unlockedFishes,
                                        unavailableFishes: taskManager.unavailableFishes,
                                        taskCompletionStreak: taskManager.fishUnlockProgress,
                                        viewModel: viewModel  // Add this line
                                    )
                                    .onDisappear {
                                        if let fish = viewModel.selectedFish {
                                            viewModel.handleFishSelection(fish: fish)
                                        }
                                    }
                                }
                
                
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    viewModel.syncPoints()
                }
            }
        }
    }
}
struct BouncingArrowView: View {
    @State private var offsetY: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: "arrow.up")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 2)
                .offset(y: offsetY)
                .onAppear {
                    withAnimation(
                        Animation
                            .easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true)
                    ) {
                        offsetY = -10
                    }
                }
            
            Text("Select a fish")
                .font(.custom("Supercell-Magic", size: 12))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 2)
        }
    }
}

extension HomeView {
    // MARK: - UI Components
    var splashAnimation: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                AnimatedView(fileName: "splashscreen.json")
                    .frame(width: geometry.size.width * 1, height: geometry.size.height * 1) // Adjusted height
                    .padding(.bottom, 0)
                    .offset(y: ((geometry.size.height)  * 6.1) )// Adjusted offset
                    .zIndex(1)
                    .scaleEffect(0.6)
            }
        }
        .frame(height: 100) // Set a fixed height for the splash animation
    }
    
    private var headerSection: some View {
           GeometryReader { geometry in
               HStack(spacing: -20) {
                   // Left side - Controls
                   VStack(alignment: .leading ,spacing: 15) {

                       // Volume Control
                       VStack(spacing: 5) {
                           Button(action: {
                               soundManager.isSoundEnabled.toggle()
                               if soundManager.isSoundEnabled {
                                   SoundManager.shared.playSound(.buttonTap)
                               }
                           }) {
                               Image(systemName: soundManager.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                   .font(.system(size: 30))
                                   .foregroundColor(.white)
                                   .padding()
                                   .background(
                                       Circle()
                                           .fill(Color.black.opacity(0.8))
                                           .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 4)
                                           .overlay(
                                               Circle()
                                                   .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                           )
                                   )
                                   .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                           }
                           Text("Audio")
                               .font(.appCaption(12))
                               .foregroundColor(.white)
                               .padding(.horizontal, 5)
                               .padding(.vertical, 5)
                               .background(
                                   RoundedRectangle(cornerRadius: 8)
                                       .fill(Color.black.opacity(0.6))
                                       .overlay(
                                           RoundedRectangle(cornerRadius: 8)
                                               .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                       )
                               )
                       }

                       // Shop Button
//                       VStack(spacing: 5) {
//                           Button(action: { viewModel.isShowingShop = true }) {
//                               Image(systemName: "cart.fill")
//                                   .font(.system(size: 30))
//                                   .foregroundColor(.white)
//                                   .padding()
//                                   .background(
//                                       Circle()
//                                           .fill(Color.green.opacity(1.0))
//                                           .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 4)
//                                           .overlay(
//                                               Circle()
//                                                   .stroke(Color.white.opacity(0.2), lineWidth: 1)
//                                           )
//                                   )
//                           }
//                           Text("Shop")
//                               .font(.appTitle(14))
//                               .foregroundColor(.white)
//                               .padding(.horizontal, 10)
//                               .padding(.vertical, 5)
//                               .background(
//                                   RoundedRectangle(cornerRadius: 8)
//                                       .fill(Color.black.opacity(0.6))
//                                       .overlay(
//                                           RoundedRectangle(cornerRadius: 8)
//                                               .stroke(Color.white.opacity(0.2), lineWidth: 1)
//                                       )
//                               )
//                       }
                   }
                   .padding(.leading, 10)
                   .padding(.top, 150)
                   .scaleEffect(0.8)

               
                   // Timer
                       VStack(spacing: 10) {
                           AnimatedView(fileName: "fisherman.json", isPlaying: isSliderDragging)
                               .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.4)
                               .offset(x: 30, y: -50)
                               .zIndex(4)
                               .scaleEffect(0.4)
                           
                           Text("\(Int(viewModel.selectedValue)) min")
                               .font(.custom("Supercell-Magic", size: 25))
                               .fontWeight(.bold)
                               .foregroundColor(.white)
                               .padding(.vertical, 5)
                               .padding(.horizontal, 10)
                               .background(Color.black.opacity(0.7))
                               .cornerRadius(10)
                           
                       }
                       .scaleEffect(1.0)

                   // Right side - Fish Selection and Shell Counter
                   VStack(alignment: .leading, spacing: 8) {
                       // Shell Counter
                       ZStack {
                           Image("ShellCounter")
                               .resizable()
                               .frame(width: 120, height: 60)
                               .onTapGesture {
                                   showShellMessage = true
                               }

                           Text("\(viewModel.userPoints)")
                               .foregroundColor(.white)
                               .font(.appTitle(25))
                               .offset(x: 15)
                       }
                       

                       // Fish Selection Button
                       VStack(spacing: 5) {
                           Button(action: { viewModel.isShowingFishSelection.toggle() }) {
                               Image("fish1")
                                   .resizable()
                                   .frame(width: 100, height: 100)
                                   .clipShape(Circle())
                           }
                           Text("School of Fish")
                               .font(.appTitle(14))
                               .foregroundColor(.white)
                               .padding(.horizontal, 5)
                               .multilineTextAlignment(.center)
                               .padding(.vertical, 5)
                               .background(
                                   RoundedRectangle(cornerRadius: 8)
                                       .fill(Color.black.opacity(0.6))
                                       .overlay(
                                           RoundedRectangle(cornerRadius: 8)
                                               .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                       )
                               )
                       }
                   }
                   .padding(.top, 50)
                   .scaleEffect(0.8)
                   
               }
               
               .frame(maxHeight: 120)
           }
        
       }
    
    var FishPotWithWater: some View {
            GeometryReader { geometry in
                ZStack {
                    // Wave Animation with Fish Pot
                    ZStack {
                        // Water Wave Animation
                        WaveView(progress: viewModel.selectedValue / 180)  // Fixed water level
                            .frame(width: geometry.size.width * 0.7, height: geometry.size.width * 0.7) // Responsive width and height
                            .opacity(0.6)
                            .zIndex(1)
                        
                        if let selectedFish = viewModel.selectedFish {
                            ZStack {
                                if viewModel.isLottieAnimated(selectedFish) {
                                    LottieView(
                                        fileName: selectedFish,
                                        loopMode: .loop,
                                        play: true
                                    )
                                    .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4) // Responsive size
                                    .clipShape(Circle())
                                    .offset(y: viewModel.fishDropCompleted ? viewModel.floatingOffset : viewModel.fishDropOffset)
                                    .zIndex(2)
                                } else {
                                    Image(selectedFish)
                                        .resizable()
                                        .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4) // Responsive size
                                        .clipShape(Circle())
                                        .offset(y: viewModel.fishDropCompleted ? viewModel.floatingOffset : viewModel.fishDropOffset)
                                        .zIndex(3)
                                }
                                
                                // Breathing Bubbles Animation
                                LottieView(
                                    fileName: "bubbles",
                                    loopMode: .loop,
                                    play: true,
                                    loopDelay: 2.0
                                )
                                .frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2) // Responsive size
                                .offset(y: (viewModel.fishDropCompleted ? viewModel.floatingOffset : viewModel.fishDropOffset) - 20)
                                .opacity(0.6)
                                .zIndex(3)
                            }
                        }
                        
                        // Water Splash Animation
                        if viewModel.showSplashAnimation {
                            LottieView(fileName: "splashwater", play: true)
                                .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)  // Responsive size
                                .offset(y: 50)  // Move splash down a bit
                                .zIndex(3)
                                .scaleEffect(0.5)  // Reduced scale
                        }
                    }
                    
                    // Circular Slider
                    CircularSlider(currentValue: $viewModel.selectedValue, isDragging: $isSliderDragging, maxValue: 180, progressColor: viewModel.selectedTag.map { viewModel.tagColor(for: $0) } ?? .indigo)
                        .frame(width: geometry.size.width * 1, height: geometry.size.height * 1) // Responsive size
                        .zIndex(0)
                    
//                    if let selectedTag = viewModel.selectedTag {
//                        Text(selectedTag)
//                            .font(.custom("Supercell-Magic", size: 25))
//                            .foregroundColor(viewModel.tagColor(for: selectedTag))
//                            .padding(.top, -400)
//                            .zIndex(5)
//                    }
                }
            }
            .frame(height: 300) // Set a fixed height for the timer and fish pot
//            .scaleEffect(0.8)
        }
    
    var TagPicker: some View {
        VStack{
            // New Tag Button
            Menu {
                Picker("Select Tag", selection: $viewModel.selectedTag) {
                    ForEach(viewModel.tagOptions, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 16))
                            .foregroundColor(viewModel.tagColor(for: tag))
                            .tag(Optional(tag))
                    }
                }
                .pickerStyle(.inline)
            } label: {
                Text(viewModel.selectedTag ?? "Select your goal >")
                    .font(.custom("Supercell-Magic", size: 16))
                    .foregroundColor(viewModel.selectedTag.map { viewModel.tagColor(for: $0) } ?? .white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke((viewModel.selectedTag.map { viewModel.tagColor(for: $0) } ?? .white).opacity(0.2), lineWidth: 1)
                            )
                    )
            }
        }
        .offset(y: 70)
    }
    // Update the sliderAndStartButton to show hint
    var StartButton: some View {
        VStack {
            if viewModel.selectedFish != nil {
                LottieView(fileName: "StartButton", play: true)
                    .frame(width: 200, height: 100)
                    .onTapGesture {
                        viewModel.isAnimationPlaying = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            viewModel.navigateToTimerScreenAction()
                        }
                    }
                    .opacity(1.0)
            } else {
                LottieView(fileName: "StartButton", play: false)
                    .frame(width: 200, height: 100)
                    .opacity(0.5)
                    .onTapGesture {
                        // Show FishSelectionView when disabled button is tapped
                        viewModel.isShowingFishSelection = true
                    }
            }
        }
        .padding()
    }
    
    var menuButton: some View {
        Button(action: { viewModel.isSideMenuOpen.toggle() }) {
            Image("menu")
                .resizable()
                .frame(width: 40, height: 40)
        }
    }
    
    var shellCounter: some View {
        Button(action: { viewModel.isShowingPopup.toggle() }) {
            ZStack {
                Image("ShellCounter")
                    .resizable()
                    .frame(width: 80, height: 50)
                
                Text("\(viewModel.userPoints)")
                    .foregroundColor(.white)
                    .font(.custom("Supercell-Magic", size: 16))
                    .bold()
                    .offset(x: 15)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
         Group {
             // Create a mock TaskCompletionManager for the preview
             let mockTaskManager = TaskCompletionManager() // Replace with your actual initialization if needed
             
             // Create a mock HomeViewModel for the preview
             let mockViewModel = HomeViewModel(taskManager: mockTaskManager)
             
             // Preview for iPhone SE (3rd generation)
             HomeView(taskManager: mockTaskManager)
                 .environmentObject(mockViewModel)
                 .preferredColorScheme(.dark)
                 .previewDevice("iPhone SE (3rd generation)")
                 .previewDisplayName("iPhone SE")
             
             // Preview for iPhone 14
             HomeView(taskManager: mockTaskManager)
                 .environmentObject(mockViewModel)
                 .preferredColorScheme(.dark)
                 .previewDevice("iPhone 16")
                 .previewDisplayName("iPhone 16")
             
             // Preview for iPhone 14 Pro Max
             HomeView(taskManager: mockTaskManager)
                 .environmentObject(mockViewModel)
                 .preferredColorScheme(.dark)
                 .previewDevice("iPhone 16 Pro Max")
                 .previewDisplayName("iPhone 16 Pro Max")
         }
     }
}
