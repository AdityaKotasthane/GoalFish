import SwiftUI

struct ResultScreen: View {
    let studyTime: Double
    let workTime: Double
    let meditateTime: Double
    let exerciseTime: Double
    let remainingTime: Int
    let isTaskCompleted: Bool
    @Binding var userPoints: Int
    @Binding var selectedFish: String?
    @ObservedObject var taskCompletionManager: TaskCompletionManager
    let backgroundCount: Int
    let timerValue: Int
    
    @AppStorage("selectedBackground") private var selectedBackground: String = "background1" // Sync background selection
    @Environment(\.dismiss) private var dismiss // To dismiss the view and return to ContentView
    
    @State private var pointsSynced = false // Prevent multiple updates
    
    var body: some View {
        ZStack {
            // Background Image
            Image(selectedBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Title
                Text(isTaskCompleted ? "Task Completed!" : "Task Failed!")
                    .font(.custom("Supercell-Magic", size: 30))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                
                // Points Update Section
                if isTaskCompleted {
                    Text("+20 Points for Task Completion")
                        .font(.custom("Supercell-Magic", size: 20))
                        .foregroundColor(.green)
                        .padding()
                } else {
                    Text("-4 Points for Task Failure")
                        .font(.custom("Supercell-Magic", size: 20))
                        .foregroundColor(.red)
                        .padding()
                }
                
                // Stats Section
                VStack(alignment: .leading, spacing: 10) {
                    statRow(title: "Time Set", value: formatTime(timerValue * 60))
                    statRow(title: "Time Remaining", value: formatTime(remainingTime))
                    statRow(title: "Times Sent to Background", value: "\(backgroundCount)")
                    statRow(title: "Total Points", value: "\(userPoints)")
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                
//                // Productivity Breakdown Section
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("Productivity Breakdown")
//                        .font(.custom("Supercell-Magic", size: 20))
//                        .foregroundColor(.white)
//                        .padding(.bottom, 5)
//                    
//                    progressBar(title: "Study", value: studyTime, color: .blue)
//                    progressBar(title: "Work", value: workTime, color: .green)
//                    progressBar(title: "Meditate", value: meditateTime, color: .purple)
//                    progressBar(title: "Exercise", value: exerciseTime, color: .orange)
//                }
//                .padding()
//                .background(Color.black.opacity(0.5))
//                .cornerRadius(10)
//                .padding(.horizontal, 20)
//                
//                Spacer()
//                
                // Return to Home Button
                Button(action: {
                    dismiss() // Navigate back to ContentView
                }) {
                    Text("Return to Home")
                        .font(.custom("Supercell-Magic", size: 20))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            syncUserPoints()
        }
    }
    
    // MARK: - Helpers
    
    private func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.custom("Supercell-Magic", size: 17))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.custom("Supercell-Magic", size: 17))
                .foregroundColor(.yellow)
        }
    }
    
    private func progressBar(title: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.custom("Supercell-Magic", size: 15))
                .foregroundColor(.white)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 10)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .frame(width: CGFloat(value / totalProductivity()) * geometry.size.width, height: 10)
                        .foregroundColor(color)
                }
            }
            .frame(height: 10)
        }
    }
    
    private func totalProductivity() -> Double {
        return studyTime + workTime + meditateTime + exerciseTime
    }
    
    private func syncUserPoints() {
        // Ensure points are synced only once per appearance
        guard !pointsSynced else { return }
        pointsSynced = true
        
        // Sync points with TaskCompletionManager
        userPoints = taskCompletionManager.userPoints
    }
}
