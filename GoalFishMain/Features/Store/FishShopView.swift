import SwiftUI

struct FishShopView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var userPoints: Int
    let allFishes: [String: String]
    let unlockedFishes: [String: String]
    @State private var showPurchaseAlert = false
    @State private var selectedFishToPurchase: (name: String, image: String)?
    
    // Fish prices (you can adjust these)
    let fishPrices: [String: Int] = [
        "fish1": 100,
        "fish2": 200,
        "fish3": 300,
        "fish4": 400,
        "fish5": 500,
        "fish6": 600,
        "fish7": 700
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            // Background
            Image(selectedBackground)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .opacity(1)
            
            VStack {
                // Header with Shell Counter
                HStack {
                    Text("Fish Shop")
                        .font(.custom("Supercell-Magic", size: 28))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2)
                    
                    Spacer()
                    
                    // Shell Counter
                    ZStack {
                        Image("ShellCounter")
                            .resizable()
                            .frame(width: 80, height: 50)
                        
                        Text("\(userPoints)")
                            .foregroundColor(.white)
                            .font(.custom("Supercell-Magic", size: 16))
                            .bold()
                            .offset(x: 15)
                    }
                }
                .padding()
                
                // Fish Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(Array(allFishes.sorted(by: { $0.key < $1.key })), id: \.key) { fishName, fishImage in
                            FishShopItem(
                                fishName: fishName,
                                fishImage: fishImage,
                                price: fishPrices[fishImage] ?? 100,
                                isOwned: unlockedFishes.values.contains(fishImage),
                                canAfford: userPoints >= (fishPrices[fishImage] ?? 100)
                            ) {
                                selectedFishToPurchase = (fishName, fishImage)
                                showPurchaseAlert = true
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .alert("Purchase Fish", isPresented: $showPurchaseAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Buy", role: .none) {
                if let fish = selectedFishToPurchase,
                   let price = fishPrices[fish.image],
                   userPoints >= price {
                    userPoints -= price
                    // Add logic to unlock fish
                }
            }
        } message: {
            if let fish = selectedFishToPurchase,
               let price = fishPrices[fish.image] {
                Text("Would you like to buy \(fish.name) for \(price) shells?")
            }
        }
    }
}

struct FishShopItem: View {
    let fishName: String
    let fishImage: String
    let price: Int
    let isOwned: Bool
    let canAfford: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: isOwned ? {} : action) {
            VStack {
                Image(fishImage)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(isOwned ? Color.green : (canAfford ? Color.blue : Color.red), lineWidth: 3)
                    )
                    .scaleEffect(isOwned ? 1.1 : 1.0)
                
                Text(fishName)
                    .font(.custom("Supercell-Magic", size: 16))
                    .foregroundColor(.white)
                
                if !isOwned {
                    HStack {
                        Image("ShellCounter")
                            .resizable()
                            .frame(width: 40, height: 25)
                        Text("\(price)")
                            .font(.custom("Supercell-Magic", size: 14))
                            .foregroundColor(.white)
                    }
                } else {
                    Text("Owned")
                        .font(.custom("Supercell-Magic", size: 14))
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black.opacity(0.3))
            )
            .opacity(isOwned ? 0.8 : 1.0)
        }
        .disabled(isOwned)
    }
}