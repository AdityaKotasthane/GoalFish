import SwiftUI

struct SideMenu: View {
    @ObservedObject var taskCompletionManager: TaskCompletionManager
    @Binding var isMenuOpen: Bool

    @State private var showStoreView = false // Tracks when to show the Store popup

    var body: some View {
        ZStack {
            // Black background that fully covers the screen
            Color.black
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        isMenuOpen = false
                    }
                }

            // Side Menu Content
            VStack(alignment: .leading, spacing: 20) {
                Text("Menu")
                    .font(.custom("Supercell-Magic", size: 20))
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 20)

                menuItem(icon: "cart.fill", title: "Store") {
                    showStoreView = true
                }

                menuItem(icon: "star.fill", title: "Achievements") {
                    // Add achievements navigation
                }

                menuItem(icon: "tag.fill", title: "Tags") {
                    // Add tags navigation
                }

                menuItem(icon: "gearshape.fill", title: "Settings") {
                    // Add settings navigation
                }

                Spacer()
            }
            .padding(.top, 50)
            .padding(.horizontal, 20)
            .frame(maxWidth: 320, alignment: .leading)
            .background(Color.black) // Side menu itself stays black
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.5), radius: 10, x: 5, y: 5)
            .offset(x: isMenuOpen ? 0 : -300)
            .animation(.easeInOut)

            Spacer()
        }
        .fullScreenCover(isPresented: $showStoreView) {
            StoreView(isShowing: $showStoreView)
        }
    }

    // MARK: - Menu Item UI
    private func menuItem(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.headline)
                Text(title)
                    .font(.custom("Supercell-Magic", size: 18))
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding(.leading, 10)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
            )
            .cornerRadius(10)
            .shadow(color: Color.blue.opacity(0.5), radius: 5, x: 0, y: 3)
        }
    }
}
