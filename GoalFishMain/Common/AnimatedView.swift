import SwiftUI
import Lottie

struct AnimatedView: UIViewRepresentable {
    let fileName: String
    var isPlaying: Bool = true  // Add this property
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: fileName)
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        if isPlaying {
            animationView.play()
        }
        
        // Add observers for pause/resume notifications
        NotificationCenter.default.addObserver(
            forName: .pauseAnimation,
            object: nil,
            queue: .main) { _ in
                animationView.pause()
        }
        
        NotificationCenter.default.addObserver(
            forName: .resumeAnimation,
            object: nil,
            queue: .main) { _ in
                animationView.play()
        }
        
        return animationView
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        if isPlaying {
            uiView.play()
        } else {
            uiView.pause()
        }
    }
}

extension AnimatedView {
    func pausable(_ shouldPause: Bool) -> some View {
        self.modifier(PausableModifier(shouldPause: shouldPause))
    }
}

struct PausableModifier: ViewModifier {
    let shouldPause: Bool
    
    func body(content: Content) -> some View {
        content
            .onChange(of: shouldPause) { _, isPaused in
                if isPaused {
                    NotificationCenter.default.post(name: .pauseAnimation, object: nil)
                } else {
                    NotificationCenter.default.post(name: .resumeAnimation, object: nil)
                }
            }
    }
}

extension Notification.Name {
    static let pauseAnimation = Notification.Name("pauseAnimation")
    static let resumeAnimation = Notification.Name("resumeAnimation")
}
