//
//  Colors.swift
//  GoalFishMain
//
//  Created by Arjun Pratap Choudhary on 08/02/25.
//
import SwiftUI
import Foundation

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
    // Brand Colors
    static let primary = Color(hex: "#4A90E2")
    static let secondary = Color(hex: "#50E3C2")
    
    // Background Colors
    static let background = Color(hex: "#F5F8FA")
    static let cardBackground = Color(hex: "#FFFFFF")
    
    // Text Colors
    static let textPrimary = Color(hex: "#2C3E50")
    static let textSecondary = Color(hex: "#7F8C8D")
    
    // Fish Theme Colors
    static let deepOcean = Color(hex: "#1B4965") // Deep blue for depth and stability
    static let aquaBreeze = Color(hex: "#5FA8D3") // Light blue for refreshing water tones
    static let coralReef = Color(hex: "#FF9A8C") // Soft coral color
    static let seaFoam = Color(hex: "#62B6AB") // Minty green-blue for ocean freshness
    static let oceanMist = Color(hex: "#CAE9FF") // Light, airy blue for surface water
    static let tropicalWaters = Color(hex: "#00B4D8") // Vibrant turquoise for tropical waters
    
    // Status Colors
    static let success = Color(hex: "#2ECC71")
    static let warning = Color(hex: "#F1C40F")
    static let error = Color(hex: "#E74C3C")
    
    // Shell Counter Colors
    static let shellGold = Color(hex: "#FFD700")
}

