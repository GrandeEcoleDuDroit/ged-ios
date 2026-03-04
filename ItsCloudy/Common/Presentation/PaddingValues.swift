import Foundation

struct PaddingValues {
    let vertical: CGFloat
    let horizontal: CGFloat
    
    init(
        vertical: CGFloat = 0,
        horizontal: CGFloat = 0
    ) {
        self.vertical = vertical
        self.horizontal = horizontal
    }
}

extension PaddingValues {
    init(_ value: CGFloat) {
        self.vertical = value
        self.horizontal = value
    }
}
