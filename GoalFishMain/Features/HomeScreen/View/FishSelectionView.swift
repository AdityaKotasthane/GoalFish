import SwiftUI

struct FishSelectionView: View {
    @Binding var selectedFish: String?
    @Binding var isShowing: Bool
    let allFishes: [String: String] // Dictionary of all fish names and images
    let taskCompletionStreak: Int // Tracks the number of tasks completed

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                Text("Select Your Fish")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 10)

                ScrollView {
                    VStack(spacing: 12) {
                        // **Show All Fishes (No Locking Mechanism)**
                        Text("Available Fishes")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.top, 5)

                        ForEach(allFishes.sorted(by: { $0.key < $1.key }), id: \.key) { fishName, fishImage in
                            fishButton(fishName: fishName, fishImage: fishImage)
                        }
                    }
                    .padding(.horizontal)
                }

                // **Close Button**
                Button(action: {
                    isShowing = false
                }) {
                    Text("Close")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarHidden(true)
            .padding(.vertical, 10)
        }
    }

    // MARK: - Fish Button
    private func fishButton(fishName: String, fishImage: String) -> some View {
        Button(action: {
            selectedFish = fishImage
            isShowing = false
        }) {
            HStack {
                Image(fishImage)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())

                Text(fishName)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                if selectedFish == fishImage {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.1)))
        }
    }
}
