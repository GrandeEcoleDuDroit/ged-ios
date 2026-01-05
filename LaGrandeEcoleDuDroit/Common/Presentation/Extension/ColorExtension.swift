import SwiftUI

extension Color {
    func hex(_ hex: String) -> Color {
        var hexSanitized = hex.trim()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        return .init(red: red, green: green, blue: blue)
    }
    
    static var click: Color {
        Color(UIColor.systemGray4)
    }
}
