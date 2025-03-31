//
//  SlideTransition.swift
//  GoalFishMain
//
//  Created by Arjun Pratap Choudhary on 13/02/25.
//


import SwiftUI

struct SlideTransition: ViewModifier {
    let isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .offset(x: isPresented ? 0 : UIScreen.main.bounds.width)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPresented)
    }
}