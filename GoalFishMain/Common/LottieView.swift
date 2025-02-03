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
    var play: Bool

    let animationView = LottieAnimationView()

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)

        animationView.animation = LottieAnimation.named(fileName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.backgroundBehavior = .pauseAndRestore

        view.addSubview(animationView)

        // Constraints for animation view
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        if play {
            animationView.play()
        }
    }
}