import SwiftUI
import Lottie

struct SplashScreen: View {
    var onTap: () -> Void
    @State private var isWaterFilling = true
    @State private var textColor: Color = .white  // Initial color state
    @AppStorage("selectedBackground") private var selectedBackground: String = "background5"
    
    var body: some View {
        ZStack {
            // Background
            Image("background5")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .opacity(1)
                .zIndex(0)
            
            // Water Fill Animation
            LottieView(
                fileName: "SplashWaterFill",
                loopMode: .playOnce,
                play: isWaterFilling
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
            .opacity(0.5)
            .zIndex(1)
            .scaleEffect(x: 1.2, y: 2.2)
            
            // Wave animation at the bottom
            VStack {
                Spacer()
                
                AnimatedView(fileName: "splashscreen.json")
                    .frame(
                        width: UIScreen.main.bounds.width,
                        height: 100
                    )
                    .opacity(0.9)
                    .padding(.bottom, 0)
                    .zIndex(5)
            }.zIndex(5)
            
            // App logo and text
            VStack {
                Spacer()
                
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .padding(.top, 50)
                    .zIndex(3)

                ZStack {
                    AnimatedView(fileName: "fishes.json")
                        .frame(width: 200, height: 50)
                        .scaleEffect(0.15)
                        .zIndex(5)

                    Text("GoalFish")
                        .font(.custom("Supercell-Magic", size: 40))
                        .fontWeight(.heavy)
                        .foregroundColor(textColor)
                        .padding(.top, 30)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)  // Add shadow
                        .overlay(  // Add text stroke
                            Text("GoalFish")
                                .font(.custom("Supercell-Magic", size: 40))
                                .fontWeight(.heavy)
                                .foregroundColor(textColor)
                                .padding(.top, 30)
                                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 0)
                        )
                        .zIndex(5)  // Increase zIndex to be above water fill
                }
                
                Spacer()
            }
            .zIndex(5)  // Ensure entire content stack is above water fill
        }
        .onAppear {
            // Change text color after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    textColor = .blue
                }
            }
            
            // Navigate after water fill animation completes (5 seconds)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isWaterFilling = false
                withAnimation {
                    onTap()
                }
            }
        }
    }
}
