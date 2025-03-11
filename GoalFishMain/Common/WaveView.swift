import SwiftUI

struct WaveView: View {
    @State private var waveOffset = Angle(degrees: 0)
    let progress: Double
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                
                Circle()
                    .scale(0.98)
                    .overlay(
                        Wave(offset: waveOffset, percent: 1 - progress)
                            .fill(Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5))
                    )
                    .clipShape(Circle().scale(0.98))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                self.waveOffset = Angle(degrees: 360)
            }
        }
    }
}