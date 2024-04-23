import SwiftUI
import Lottie

struct SplashScreen: View {
    var onTap: () -> Void // Define a closure to handle tap

    var body: some View {
        ZStack {
            Color.blue
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .padding(.top, 50) // Adjust top padding to center vertically

                Text("GoalFish")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 20)

                Spacer()

                AnimatedView(fileName: "splashscreen.json")
                    .frame(
                        width: UIScreen.main.bounds.width * 0.5, // Reduce the width by 50%
                        height: 50 // Keep the height at 100
                    )
                    .padding(.bottom, 20) // Add padding to create space between logo and animation
            }
        }
        .onTapGesture { // Handle tap gesture
            onTap()
        }
    }
}
