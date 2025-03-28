import SwiftUI

@main
struct GoalFishApp: App {
    @State private var showSplash = true
    
    // Initialize core services and managers
    private let taskCompletionManager = TaskCompletionManager()
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreen {
                    withAnimation {
                        showSplash = false
                    }
                }
            } else {
                // Pass the taskCompletionManager to HomeView
                HomeView(taskManager: taskCompletionManager)
                    .environmentObject(taskCompletionManager) // Make it available throughout the app
                    .onAppear {
                        setupAppearance()
                    }
            }
        }
    }
    
    // Configure global app appearance
    private func setupAppearance() {
        // Set navigation bar appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        navigationBarAppearance.backgroundColor = .clear
        
        // Apply navigation bar appearance
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        
        // Hide navigation bar back button text
        UINavigationBar.appearance().tintColor = .white
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
    }
}
