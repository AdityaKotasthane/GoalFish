import SwiftUI

struct RadialGaugeChart: View {
    let remainingTime: Int
    let focusTime: Int
    
    private var totalDuration: Int {
        return focusTime + remainingTime
    }
    
    private var progress: CGFloat {
        return CGFloat(remainingTime) / CGFloat(totalDuration)
    }
    
    private var startAngle: Angle {
        return .degrees(-90)
    }
    
    private var endAngle: Angle {
        return .degrees(Double(progress) * 360 - 90)
    }
    
    var body: some View {
        VStack {
            ZStack {
                // Background Circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                // Progress Arc
                ArcShape(startAngle: startAngle, endAngle: endAngle)
                    .stroke(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .leading, endPoint: .trailing), lineWidth: 20)
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1))
                
                // Inner Circle for gauge completion
                Circle()
                    .fill(Color.white)
                    .frame(width: 160, height: 160)
                
                // Text Inside Gauge
                Text("\(remainingTime) s")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding()
            
            // Status Text
            Text("Remaining Time")
                .foregroundColor(.white)
                .font(.headline)
                .padding()
                .background(Color.blue.opacity(0.7))
                .cornerRadius(10)
                .padding()
        }
        .frame(width: 200, height: 250)
    }
}

struct ArcShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        return path
    }
}

struct RadialGaugeChart_Previews: PreviewProvider {
    static var previews: some View {
        RadialGaugeChart(remainingTime: 300, focusTime: 600)
            .background(Color.black)
    }
}
