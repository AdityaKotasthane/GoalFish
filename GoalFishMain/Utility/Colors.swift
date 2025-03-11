//
//  for.swift
//  GoalFishMain
//
//  Created by Arjun Pratap Choudhary on 08/02/25.
//


// Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Colors struct for centralized management
struct Colors {
    static let color_ffffff = Color(hex: "#ffffff")  // White
    static let color_000000 = Color(hex: "#000000")  // Black
    static let color_282828 = Color(hex: "#282828")  // Dark Gray
    static let theme_bg_color = Color(hex: "#101010") // Theme Background
    // Add more colors as needed
}

// Usage in Views
Text("Hello World")
    .foregroundColor(Colors.color_ffffff)
    .background(Colors.theme_bg_color)