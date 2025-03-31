//
//  Bubble.swift
//  GoalFishMain
//
//  Created by Arjun Pratap Choudhary on 18/03/25.
//


import SwiftUI

struct Bubble: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
    var speed: Double
    
    static func random(in rect: CGRect) -> Bubble {
        let size = CGFloat.random(in: 10...30)
        let x = CGFloat.random(in: (rect.minX + size)...(rect.maxX - size))
        return Bubble(
            position: CGPoint(x: x, y: rect.maxY + size),
            size: size,
            opacity: Double.random(in: 0.3...0.7),
            speed: Double.random(in: 1.0...2.0)
        )
    }
}