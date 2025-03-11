import SwiftUI

struct AquaticTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<4) { index in
                TabBarButton(
                    imageName: getImageName(for: index),
                    title: getTitle(for: index),
                    isSelected: selectedTab == index,
                    action: { selectedTab = index }
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(hex: "#1B4965"))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color(hex: "#5FA8D3"), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.2), radius: 10, y: -5)
        )
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private func getImageName(for index: Int) -> String {
        switch index {
        case 0: return "house.fill"
        case 1: return "chart.bar.fill"
        case 2: return "fish.fill"
        case 3: return "gearshape.fill"
        default: return ""
        }
    }
    
    private func getTitle(for index: Int) -> String {
        switch index {
        case 0: return "Home"
        case 1: return "Stats"
        case 2: return "Fish"
        case 3: return "Settings"
        default: return ""
        }
    }
}

struct TabBarButton: View {
    let imageName: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: imageName)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                    .overlay(
                        isSelected ?
                            LottieView(fileName: "bubbles", loopMode: .loop, play: true)
                                .frame(width: 40, height: 40)
                                .opacity(0.6)
                        : nil
                    )
                
                Text(title)
                    .font(.custom("Supercell-Magic", size: 12))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}