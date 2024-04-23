import SwiftUI

@main
struct GoalFishApp: App {
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreen { // Pass a closure to SplashScreen to handle tap
                    withAnimation {
                        showSplash = false
                    }
                }
            } else {
                ContentView()
            }
        }
    }
}
