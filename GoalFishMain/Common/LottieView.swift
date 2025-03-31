//
//  LottieView.swift
//  GoalFishMain
//
//  Created by Arjun Pratap Choudhary on 22/10/24.
//


import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var fileName: String
    var loopMode: LottieLoopMode = .playOnce
    var play: Bool
    var loopDelay: TimeInterval? = nil

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: fileName) // Create here instead of as property
        
        animationView.animation = LottieAnimation.named(fileName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.backgroundBehavior = .pauseAndRestore
        
        // Set up delayed loop if specified
        if let delay = loopDelay {
            // Use completion block instead of completion handler
            animationView.play { finished in
                if finished {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        animationView.play()
                    }
                }
            }
        } else if play {
            animationView.play()
        }
        
        view.addSubview(animationView)
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        if let animationView = uiView.subviews.first as? LottieAnimationView {
            if play && !animationView.isAnimationPlaying {
                animationView.play()
            }
        }
    }
}
