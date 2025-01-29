import SwiftUI

struct ShellCounterView: View {
    @Binding var shellsCount: Int
    @Binding var isShowingPopup: Bool

    var body: some View {
        HStack {
            ZStack {
                // Background for the counter
                Image("UI-Counter-BG")
                    .resizable()
                    .frame(width: 100, height: 40) // Adjust size as needed

                // Shell count text
                Text("\(shellsCount)")
                    .foregroundColor(.white)
                    .bold()
                    .padding(.leading, 30) // Adjust padding to align text in the center of the rectangle
            }

            // Plus icon as a button
            Button(action: {
                isShowingPopup = true // Show popup when clicked
            }) {
                Image("Plus") // Plus icon image
                    .resizable()
                    .frame(width: 25, height: 25) // Adjust size as needed
                    .offset(x: -20) // Position the Plus icon next to the shell counter
            }
            .sheet(isPresented: $isShowingPopup) {
                // Empty popup for now
                VStack {
                    Text("Add more shells here!")
                    Button("Close") {
                        isShowingPopup = false
                    }
                }
                .padding()
            }
        }
    }
}
