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

    @AppStorage("selectedBackground") private var selectedBackground: String = "background1"
    @Environment(\.dismiss) private var dismiss
    @State private var pointsSynced = false
    @State private var showConfetti = false // 🎉 For celebration animation

    var body: some View {
        ZStack {
            // **Background**
            Image(selectedBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .overlay(Color.black.opacity(0.05)) // Dark overlay for visibility

            VStack(spacing: 20) {
                // **Result Title**
                Text(isTaskCompleted ? "🎉 Task Completed!" : "❌ Task Failed!")
                    .font(.custom("Supercell-Magic", size: 30))
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(isTaskCompleted ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                            .shadow(radius: 10)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 2, y: 2)

                // **Medal / Failure Icon**
                Image(isTaskCompleted ? "medal" : "failed_icon") // Replace with actual asset names
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .shadow(radius: 5)
                    .animation(.easeInOut(duration: 0.5), value: isTaskCompleted)

                // **Points Update**
                Text(isTaskCompleted ? "+20 Points 🎉" : "-4 Points ")
                    .font(.custom("Supercell-Magic", size: 22))
                    .foregroundColor(isTaskCompleted ? .green : .red)
                    .padding(.vertical, 5)
                    .shadow(color: .black.opacity(0.1), radius: 2)

                // **Stats Box**
                statsBox

                Spacer()

                // **Return Home Button**
                Button(action: {
                    dismiss()
                }) {
                    Text("Return to Home")
                        .font(.custom("Supercell-Magic", size: 22))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.7)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
            .padding(.top, 30)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            syncUserPoints()
            if isTaskCompleted {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showConfetti = true
                }
            }
        }
    }

    // **Stats Box**
    private var statsBox: some View {
        VStack(spacing: 12) {
            statRow(title: "⏳ Time Set", value: formatTime(timerValue * 60))
            statRow(title: "⏰ Time Remaining", value: formatTime(remainingTime))
            statRow(title: "📲 Times Sent to Background", value: "\(backgroundCount)")
            statRow(title: "🏆 Total Points", value: "\(userPoints)")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                )
                .shadow(radius: 5)
        )
        .padding(.horizontal, 20)
    }

    // **Format Time**
    private func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // **Stat Row**
    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.custom("Supercell-Magic", size: 18))
                .foregroundColor(.white)

            Spacer()

            Text(value)
                .font(.custom("Supercell-Magic", size: 18))
                .foregroundColor(.black)
                .shadow(color: .black.opacity(0.3), radius: 2)
        }
        .padding(.horizontal)
    }

    // **Sync User Points**
    private func syncUserPoints() {
        guard !pointsSynced else { return }
        pointsSynced = true
        userPoints = taskCompletionManager.userPoints
    }
}
