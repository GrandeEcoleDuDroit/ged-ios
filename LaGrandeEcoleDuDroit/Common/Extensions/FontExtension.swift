import SwiftUI

extension Font {
    private static func gedFont(size: CGFloat) -> Font {
        Font.custom("GedFont", size: size)
    }
    
    private static func gedFont(size: CGFloat, weight: Weight) -> Font {
        Font.system(size: size, weight: weight)
    }
    
    static var titleLarge: Font {
        .gedFont(size: 22)
    }
    
    static var titleMedium: Font {
        .gedFont(size: 18, weight: .semibold)
    }
    
    static var titleSmall: Font {
        .gedFont(size: 16, weight: .medium)
    }
    
    static var bodyLarge: Font {
        .gedFont(size: 18)
    }
    
    static var bodyMedium: Font {
        .gedFont(size: 15)
    }
}
