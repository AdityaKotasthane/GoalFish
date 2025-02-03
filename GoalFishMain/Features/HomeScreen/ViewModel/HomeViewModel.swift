////
////  HomeViewModel.swift
////  GoalFishMain
////
////  Created by Arjun Pratap Choudhary on 03/02/25.
////
//
//
//import SwiftUI
//import Combine
//
//class HomeViewModel: ObservableObject {
//    // MARK: - Published Properties
//    @Published var selectedValue: Double = 10
//    @Published var isTiming: Bool = false
//    @Published var timeRemaining: Double = 0
//    @Published var isShowingFishSelection: Bool = false
//    @Published var isShowingTagList: Bool = false
//    @Published var isSideMenuOpen: Bool = false
//    @Published var selectedFish: String?
//    @Published var selectedTag: String?
//    @Published var userPoints: Int = 0
//    @Published var selectedBackground: String = "background3"
//    @Published var floatingOffset: CGFloat = 0
//    
//    // MARK: - Constants
//    let tagOptions = Task.TaskCategory.allCases.map { $0.rawValue }
//    let tagColors: [Color] = [.green, .blue, .orange, .purple]
//    let allFishes = [
//        "Fishy": "fish1",
//        "Nemo": "fish2",
//        "Starfish": "fish3",
//        "Turtle": "fish4",
//        "Squid": "fish5",
//        "Bluey": "fish6"
//    ]
//    
//    // MARK: - Private Properties
//    private var timer: Timer?
//    private let taskManager: TaskCompletionManager
//    private var cancellables = Set<AnyCancellable>()
//    
//    // MARK: - Initialization
//    init(taskManager: TaskCompletionManager) {
//        self.taskManager = taskManager
//        setupBindings()
//    }
//    
//    // MARK: - Private Methods
//    private func setupBindings() {
//        taskManager.$userPoints
//            .assign(to: \.userPoints, on: self)
//            .store(in: &cancellables)
//    }
//    
//    // MARK: - Public Methods
//    func selectFish(_ fish: String) {
//        selectedFish = fish
//        isShowingFishSelection = false
//    }
//    
//    func selectTag(_ tag: String) {
//        selectedTag = tag
//        isShowingTagList = false
//    }
//    
//    func startTimer() {
//        guard let tag = selectedTag, let fish = selectedFish else { return }
//        isTiming = true
//        timeRemaining = selectedValue * 60
//        
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
//            self?.updateTimer()
//        }
//    }
//    
//    func updateTimer() {
//        if timeRemaining > 0 {
//            timeRemaining -= 1
//        } else {
//            stopTimer()
//        }
//    }
//    
//    func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//        isTiming = false
//    }
//    
//    func toggleSideMenu() {
//        withAnimation {
//            isSideMenuOpen.toggle()
//        }
//    }
//    
//    func syncPoints() {
//        taskManager.syncPoints()
//    }
//}
