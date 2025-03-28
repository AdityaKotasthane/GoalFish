//import SwiftUI
//
//struct StoreView: View {
//    @Binding var isShowing: Bool
//    @AppStorage("selectedBackground") private var selectedBackground: String = "background1"
//    @AppStorage("userPoints") private var userPoints: Int = 0
//
//    let availableBackgrounds = [
//        ("Background 1", "background1", 0),
//        ("Background 2", "background2", 10),
//        ("Background 3", "background3", 20),
//        ("Background 4", "background4", 30),
//        ("Background 5", "background5", 40)
//    ]
//
//    @State private var unlockedBackgrounds: [String] = ["background1"] // Default unlocked
//    @State private var unlockDates: [String: Date] = [:] // Track unlock dates
//    @State private var showAlert = false
//    @State private var alertMessage = ""
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                // Title
//                Text("Store")
//                    .font(.custom("Supercell-Magic", size: 28))
//                    .padding()
//
//                // User points
//                Text("Your Points: \(userPoints)")
//                    .font(.custom("Supercell-Magic", size: 18))
//                    .foregroundColor(.blue)
//                    .padding(.bottom)
//
//                // Background list
//                List {
//                    ForEach(availableBackgrounds, id: \.1) { name, background, cost in
//                        HStack {
//                            Image(background)
//                                .resizable()
//                                .frame(width: 50, height: 50)
//                                .cornerRadius(8)
//
//                            VStack(alignment: .leading) {
//                                Text(name)
//                                    .font(.headline)
//
//                                Text("\(cost) Points")
//                                    .font(.subheadline)
//                                    .foregroundColor(isUnlocked(background) ? .green : .red)
//                            }
//                            Spacer()
//
//                            if isUnlocked(background) {
//                                Button("Select") {
//                                    selectedBackground = background
//                                    alertMessage = "Selected \(name)!"
//                                    showAlert = true
//                                }
//                                .buttonStyle(.borderedProminent)
//                            } else {
//                                Button("Unlock") {
//                                    handleUnlock(background, cost: cost, name: name)
//                                }
//                                .buttonStyle(.bordered)
//                                .foregroundColor(userPoints >= cost ? .blue : .gray)
//                                .disabled(userPoints < cost)
//                            }
//                        }
//                    }
//                }
//
//                // Close button
//                Button("Close") {
//                    isShowing = false
//                }
//                .buttonStyle(.borderedProminent)
//                .padding()
//            }
//            .alert(isPresented: $showAlert) {
//                Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//            }
//            .onAppear {
//                loadUnlockData()
//            }
//            .navigationBarHidden(true)
//        }
//    }
//
//    private func handleUnlock(_ background: String, cost: Int, name: String) {
//        if userPoints >= cost {
//            unlockedBackgrounds.append(background)
//            unlockDates[background] = Date()
//            userPoints -= cost
//            selectedBackground = background
//            saveUnlockData()
//            alertMessage = "Unlocked and selected \(name)!"
//        } else {
//            alertMessage = "Not enough points to unlock \(name)."
//        }
//        showAlert = true
//    }
//
//    private func isUnlocked(_ background: String) -> Bool {
//        if unlockedBackgrounds.contains(background), let unlockDate = unlockDates[background] {
//            let daysUnlocked = Calendar.current.dateComponents([.day], from: unlockDate, to: Date()).day ?? 0
//            return daysUnlocked <= 5 // Check if unlocked within 5 days
//        }
//        return background == "background1" // Default background is always unlocked
//    }
//
//    private func saveUnlockData() {
//        let encoder = JSONEncoder()
//        if let data = try? encoder.encode(unlockDates) {
//            UserDefaults.standard.set(data, forKey: "unlockDates")
//        }
//        UserDefaults.standard.set(unlockedBackgrounds, forKey: "unlockedBackgrounds")
//    }
//
//    private func loadUnlockData() {
//        if let data = UserDefaults.standard.data(forKey: "unlockDates"),
//           let decodedDates = try? JSONDecoder().decode([String: Date].self, from: data) {
//            unlockDates = decodedDates
//        }
//        if let storedBackgrounds = UserDefaults.standard.array(forKey: "unlockedBackgrounds") as? [String] {
//            unlockedBackgrounds = storedBackgrounds
//        }
//    }
//}
