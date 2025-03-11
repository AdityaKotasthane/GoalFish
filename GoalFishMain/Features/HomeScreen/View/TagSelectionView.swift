import SwiftUI

struct TagSelectionView: View {
    @Binding var selectedTag: String?
    @Binding var isShowing: Bool
    let tagOptions: [String]
    let tagColors: [Color]
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Select Task Type")
                .font(.title)
                .padding()
            
            ForEach(0..<tagOptions.count, id: \.self) { index in
                Button(action: {
                    selectedTag = tagOptions[index]
                    isShowing = false
                }) {
                    Text(tagOptions[index])
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(tagColors[index])
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            Button("Cancel") {
                isShowing = false
            }
            .padding()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}