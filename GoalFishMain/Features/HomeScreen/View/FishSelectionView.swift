import SwiftUI

struct FishSelectionView: View {
    @Binding var selectedFish: String?
    @Binding var isShowing: Bool
    @Binding var selectedTab: Int
    let allFishes: [String: String]
    let unlockedFishes: [String: String]
    let unavailableFishes: [String]
    let taskCompletionStreak: Int
    let viewModel: HomeViewModel  // Add this line
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                Text("Select Your Fish")
                    .font(.custom("Supercell-Magic", size: 24))
                    .fontWeight(.bold)
                    .padding(.top, 10)
                
                ScrollView {
                    VStack(spacing: 12) {
                        Text("Your Fishes")
                            .font(.custom("Supercell-Magic", size: 14))
                            .foregroundColor(.blue)
                            .padding(.top, 5)
                        
                        // Only show unlocked and available fishes
                        ForEach(unlockedFishes.sorted(by: { $0.key < $1.key }), id: \.key) { fishName, fishImage in
                            if !unavailableFishes.contains(fishImage) {
                                fishButton(fishName: fishName, fishImage: fishImage)
                            }
                        }
                        
                        // Show locked fishes message
                        if unlockedFishes.count < allFishes.count {
                            VStack(spacing: 8) {
                                Text("More fishes available!")
                                    .font(.custom("Supercell-Magic", size: 16))
                                    .foregroundColor(.gray)
                                
                                Button(action: {
                                    isShowing = false
                                    selectedTab = 1  // Switch to Fish Shop tab
                                }){
                                    Text("Visit Fish Shop")
                                        .font(.custom("Supercell-Magic", size: 14))
                                        .foregroundColor(.blue)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.blue, lineWidth: 1)
                                        )
                                }
                            }
                            .padding(.top, 20)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Button(action: { isShowing = false }) {
                    Text("Close")
                        .font(.custom("Supercell-Magic", size: 18))
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
    
    private func fishButton(fishName: String, fishImage: String) -> some View {
           Button(action: {
               selectedFish = fishImage
               isShowing = false
           }) {
               HStack {
                   if viewModel.isLottieAnimated(fishImage) {
                       LottieView(
                           fileName: fishImage,
                           loopMode: .loop,
                           play: true
                       )
                       .frame(width: 80, height: 80)
                       .clipShape(Circle())
                   } else {
                       Image(fishImage)
                           .resizable()
                           .frame(width: 80, height: 80)
                           .clipShape(Circle())
                   }
                   
                   Text(fishName)
                       .font(.custom("Supercell-Magic", size: 20))
                       .foregroundColor(.primary)
                   
                   Spacer()
                   
                   if selectedFish == fishImage {
                       Image(systemName: "checkmark.circle.fill")
                           .foregroundColor(.green)
                   }
               }
               .padding()
               .background(RoundedRectangle(cornerRadius: 30).fill(Color.blue.opacity(0.1)))
           }
       }
}
