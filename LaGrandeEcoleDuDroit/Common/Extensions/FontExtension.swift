import SwiftUI

extension Font {
    private static func gedFont(size: CGFloat, style: Font.TextStyle) -> Font {
        Font.custom("GedFont", size: size, relativeTo: style)
    }
    
    private static func gedFont(size: CGFloat, weight: Weight) -> Font {
        Font.system(size: size, weight: weight)
    }
    
    static var titleLarge: Font {
        .gedFont(size: 22, style: .title)
    }
    
    static var titleMedium: Font {
        .gedFont(size: 18, weight: .semibold)
    }
    
    static var titleSmall: Font {
        .gedFont(size: 16, weight: .medium)
    }
    
    static var bodyLarge: Font {
        .gedFont(size: 18, style: .title3)
    }
    
    static var bodyMedium: Font {
        .gedFont(size: 15, weight: .regular)
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Title Large")
            .font(.titleLarge)
        
        Text("Title Medium")
            .font(.titleMedium)
        
        Text("Title Small")
            .font(.titleSmall)
        
        Text("Title")
            .font(.title)
        
        Text("Title 2")
            .font(.title2)
        
        Text("Title 3")
            .font(.title3)
        
        Text("Body Large")
            .font(.bodyLarge)
        
        Text("Body Medium")
            .font(.bodyMedium)
        
        Text("Body")
            .font(.body)
    }
}
