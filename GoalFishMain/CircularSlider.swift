import SwiftUI

public struct CircularSlider: View {
    @Binding var currentValue: Double
    var minValue: Double = 0
    var maxValue: Double = 100
    var knobRadius: Double = 11
    var progressLineColor: Color = .green
    var trackColor: Color = .gray.opacity(0.2)
    var lineWidth: Double = 20
    var backgroundColor: Color = .clear
    var onValueSelection: ((Double) -> ())?

    @State private var angle: Double = 0

    public init(
        currentValue: Binding<Double>,
        minValue: Double = 0,
        maxValue: Double = 100,
        knobRadius: Double = 11,
        progressLineColor: Color = .green,
        trackColor: Color = .gray.opacity(0.2),
        lineWidth: Double = 15,
        backgroundColor: Color = .clear,
        onValueSelection: ((Double) -> ())? = nil
    ) {
        self._currentValue = currentValue
        self.minValue = minValue
        self.maxValue = maxValue
        self.knobRadius = knobRadius
        self.progressLineColor = progressLineColor
        self.trackColor = trackColor
        self.lineWidth = lineWidth
        self.backgroundColor = backgroundColor
        self.onValueSelection = onValueSelection
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background circle
                Circle()
                    .foregroundColor(backgroundColor)
                    .frame(width: geometry.size.width, height: geometry.size.height)

                // Track line
                Circle()
                    .stroke(trackColor, style: StrokeStyle(lineWidth: lineWidth * 1.3, lineCap: .butt))
                    .frame(width: geometry.size.width, height: geometry.size.height)

                // Progress line
                Circle()
                    .trim(from: 0.0, to: valueAsPercentage(value: currentValue))
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .foregroundColor(progressLineColor)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .rotationEffect(.degrees(-90))

                // Custom Knob (Compass Image)
                Image("ShipWheel") // Replace with actual image
                    .resizable()
                    .frame(width: knobRadius * 4.0, height: knobRadius * 4.0)
                    .rotationEffect(Angle(degrees: currentValueToAngle())) // Rotate based on slider value
                    .offset(y: -geometry.size.width / 2)
                    .rotationEffect(Angle.degrees(angle))
                    .zIndex(2)

                // Invisible knob for easier drag
                Circle()
                    .fill(Color.blue.opacity(0.000001))
                    .frame(width: knobRadius * 6, height: knobRadius * 6)
                    .offset(y: -geometry.size.width / 2)
                    .rotationEffect(Angle.degrees(angle))
                    .gesture(
                        DragGesture(minimumDistance: 0.0)
                            .onChanged { value in
                                change(location: value.location, size: geometry.size)
                            }
                            .onEnded { _ in
                                onValueSelection?(currentValue)
                            }
                    )
                    .zIndex(2)
            }
            .onAppear {
                currentValue = max(min(currentValue, maxValue), minValue)
                angle = valueToAngle(value: currentValue)
            }
            .onChange(of: currentValue) { newValue in
                currentValue = max(min(newValue, maxValue), minValue)
                angle = valueToAngle(value: newValue)
            }
        }
    }

    // MARK: - Helper Functions

    private func change(location: CGPoint, size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let vector = CGVector(dx: location.x - center.x, dy: location.y - center.y)
        let angleInRadians = atan2(vector.dy, vector.dx) + .pi / 2.0

        let fixedAngle = angleInRadians < 0 ? angleInRadians + 2 * .pi : angleInRadians
        let newValue = angleToValue(angleInRadians: fixedAngle)

        // Update current value and angle
        currentValue = max(min(newValue, maxValue), minValue)
        angle = radiansToDegrees(fixedAngle)
    }

    private func angleToValue(angleInRadians: Double) -> Double {
        let angleAsPercentage = angleInRadians / (2.0 * .pi)
        return angleAsPercentage * (maxValue - minValue) + minValue
    }

    private func valueToAngle(value: Double) -> Double {
        return 360 * valueAsPercentage(value: value)
    }

    private func valueAsPercentage(value: Double) -> Double {
        return (value - minValue) / (maxValue - minValue)
    }

    private func radiansToDegrees(_ radians: Double) -> Double {
        return radians * 180 / .pi
    }

    private func currentValueToAngle() -> Double {
        return (currentValue / maxValue) * 360
    }
}
