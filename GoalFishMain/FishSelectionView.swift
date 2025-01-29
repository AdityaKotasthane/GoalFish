import SwiftUI

struct FishSelectionView: View {
    @Binding var selectedFish: String?
    @Binding var isShowing: Bool
    let allFishes: [String: String]
    let unlockedFishes: [String: String]
    let unavailableFishes: [String]
    let taskCompletionStreak: Int // Tracks the number of tasks completed

    var body: some View {
        NavigationView {
            VStack {
                Text("Select Your Fish")
                    .font(.title)
                    .padding()

                List(allFishes.sorted(by: { $0.key < $1.key }), id: \.key) { fishName, fishImage in
                    Button(action: {
                        if unlockedFishes.keys.contains(fishName), !unavailableFishes.contains(fishName) {
                            selectedFish = fishImage
                            isShowing = false
                        }
                    }) {
                        HStack {
                            Text(fishName)
                            Spacer()
                            Image(unlockedFishes[fishName] ?? "default_fish_image")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .grayscale(unavailableFishes.contains(fishName) ? 1.0 : 0.0)
                        }
                    }
                    .disabled(!unlockedFishes.keys.contains(fishName) || unavailableFishes.contains(fishName))
                }

                Text("Tasks Completed for Next Unlock: \(taskCompletionStreak % 3)/3")
                    .font(.footnote)
                    .padding()

                Button("Close") {
                    isShowing = false
                }
                .padding()
            }
            .navigationBarTitle("Fish Selection", displayMode: .inline)
        }
    }
}
