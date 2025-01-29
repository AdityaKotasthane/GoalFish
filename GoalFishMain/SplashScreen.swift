import SwiftUI
import Lottie

struct SplashScreen: View {
    var onTap: () -> Void // Define a closure to handle tap

    var body: some View {
        ZStack {
            // Background at the bottom of the view hierarchy
            Image("background3")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .opacity(1)
                .zIndex(0) // Ensure background is at the bottom

            // Splash screen animation placed just above the background at the bottom
            VStack {
                Spacer()
                
                AnimatedView(fileName: "splashscreen.json")
                    .frame(
                        width: UIScreen.main.bounds.width,
                        height: 100
                    )
                    .padding(.bottom, 0) // Stick it at the bottom
                    .zIndex(1)
            }
            
            // App logo and text in the center
            VStack {
                Spacer()
                
                // App logo image in the center
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .padding(.top, 50)
                    .zIndex(2)

                // App title text below the logo
                ZStack {
                    // Fishes animation precisely over the text
                    AnimatedView(fileName: "fishes.json")
                        .frame(width: 200, height: 50) // Adjust the frame to match the text width
                        .scaleEffect(0.15) // Keep the smaller size for fishes
                        .zIndex(3) // Fishes animation above the text

                    // App text just below the fishes animation
                    Text("GoalFish")
                        .font(.custom("Supercell-Magic", size: 40))
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.top, 30)
                        .zIndex(2) // Text below the fishes animation
                }
                
                Spacer()
            }
        }
        .onTapGesture {
            onTap()
        }
    }
}
