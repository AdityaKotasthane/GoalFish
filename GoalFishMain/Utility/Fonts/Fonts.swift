//
//  Fonts.swift
//  FocusFish
//
//  Created by Arjun Pratap Choudhary on 24/02/25.
//

import SwiftUI

extension Font {
    static func appTitle(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }
    
    static func appHeading(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    static func appBody(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
    
    static func appCaption(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
}
