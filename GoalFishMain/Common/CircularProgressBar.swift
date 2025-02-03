import SwiftUI

struct CircularProgressBar: View {
    var progress: CGFloat
    var lineWidth: CGFloat
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.1), style: StrokeStyle(lineWidth: lineWidth))
                    .frame(width: geometry.size.width, height: geometry.size.width) // Ensures square circle
                
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: progress)
                    .frame(width: geometry.size.width, height: geometry.size.width) // Same width and height for consistency
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Make sure it's centered and occupies available space
        }
    }
}

struct CircularProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressBar(progress: 0.5, lineWidth: 15, color: Color.green)
            .frame(width: 260, height: 260 ) // Consistent frame for testing
    }
}
