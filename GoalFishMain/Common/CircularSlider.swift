import SwiftUI

struct CircularSlider: View {
    @Binding var currentValue: Double
    let maxValue: Double
    
    // Constants for customization
    private let lineWidth: CGFloat = 20
    private let knobSize: CGFloat = 30
    private let radius: CGFloat = 150
    private let minValue: Double = 0
    
    // Add state for tracking previous value for haptic feedback
    @State private var previousValue: Double = 0
    @State private var hapticGenerator = UISelectionFeedbackGenerator()
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: lineWidth)
            
            // Progress track
            Circle()
                .trim(from: 0, to: CGFloat(currentValue / maxValue))
                .stroke(Color.green, lineWidth: lineWidth)
                .rotationEffect(.degrees(-90))
            
            // Knob
            Circle()
                .fill(Color.white)
                .frame(width: knobSize, height: knobSize)
                .shadow(radius: 2)
                .offset(y: -radius)
                .rotationEffect(.degrees(currentValue * (360 / maxValue)))
        }
        .frame(width: radius * 2, height: radius * 2)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    hapticGenerator.prepare() // Prepare the generator
                    let oldValue = currentValue
                    updateSliderValue(at: value.location)
                    
                    // Provide haptic feedback based on movement
                    if abs(currentValue - previousValue) >= 1 { // Threshold for haptic feedback
                        hapticGenerator.selectionChanged()
                        previousValue = currentValue
                        
                        // Additional impact feedback at specific intervals
                        if Int(currentValue) % 15 == 0 { // Every 15 minutes
                            HapticManager.shared.mediumImpact()
                        }
                    }
                    
                    // Strong feedback at limits
                    if (currentValue == minValue || currentValue == maxValue) && oldValue != currentValue {
                        HapticManager.shared.heavyImpact()
                    }
                }
                .onEnded { _ in
                    // Final feedback when drag ends
                    HapticManager.shared.lightImpact()
                }
        )
        .onAppear {
            currentValue = max(minValue, currentValue)
            previousValue = currentValue
            hapticGenerator.prepare()
        }
    }
    
    private func updateSliderValue(at location: CGPoint) {
        // Existing updateSliderValue implementation...
        let vector = CGVector(dx: location.x - radius, dy: location.y - radius)
        var angle = atan2(vector.dy, vector.dx) * 180 / .pi
        
        angle += 90
        if angle < 0 {
            angle += 360
        }
        
        var newValue = (angle / 360) * maxValue
        
        if angle > 270 && currentValue < maxValue / 4 {
            newValue = minValue
        } else if angle < 90 && currentValue > maxValue * 3 / 4 {
            newValue = maxValue
        }
        
        newValue = max(minValue, min(maxValue, newValue))
        currentValue = newValue
    }
}
// Preview
struct CircularSlider_Previews: PreviewProvider {
    static var previews: some View {
        CircularSlider(currentValue: .constant(60), maxValue: 180)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

