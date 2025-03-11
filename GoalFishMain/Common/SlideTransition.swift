import SwiftUI

struct SlideTransition: ViewModifier {
    let isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .offset(x: isPresented ? 0 : UIScreen.main.bounds.width)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPresented)
    }
}