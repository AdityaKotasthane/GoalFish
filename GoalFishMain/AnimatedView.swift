import SwiftUI
import Lottie
struct AnimatedView: UIViewRepresentable {
    let fileName: String

    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: fileName)
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.play()
        return animationView
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}
