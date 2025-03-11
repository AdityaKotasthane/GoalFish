//
//  Wave.swift
//  GoalFishMain
//
//  Created by Arjun Pratap Choudhary on 04/02/25.
//


import SwiftUI

struct Wave: Shape {
    var offset: Angle
    var percent: Double
    
    var animatableData: AnimatablePair<Double, Double> {
        get {
            AnimatablePair(offset.degrees, percent)
        }
        set {
            offset = Angle(degrees: newValue.first)
            percent = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midWidth = width / 2
        let midHeight = height * (1 - percent)
        
        let wavelength = width
        let amplitude: CGFloat = 20
        
        path.move(to: CGPoint(x: 0, y: height))
        
        for x in stride(from: 0, through: width, by: 2) {
            let relativeX = x/wavelength
            let sine = sin(relativeX * 2 * .pi + offset.radians)
            let y = midHeight + amplitude * sine
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        
        return path
    }
}