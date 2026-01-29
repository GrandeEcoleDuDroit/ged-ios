import SwiftUI

struct DimensResource {
    static let extraSmallPadding: CGFloat = 4
    static let smallPadding: CGFloat = 8
    static let smallMediumPadding: CGFloat = 12
    static let mediumPadding: CGFloat = 16
    static let mediumLargePadding: CGFloat = 20
    static let largePadding: CGFloat = 24
    static let extraLargePadding: CGFloat = 32
    static let veryExtraLargePadding: CGFloat = 64
    
    static let defaultImageSize: CGFloat = 100
    static let leadingIconSpacing: CGFloat = 14
    static let inputIconSize: CGFloat = 18
    static let iconSize: CGFloat = 18
    
    static let toolbarPadding = PaddingValues(vertical: 10, horizontal: 16)
    static let toolbarItemSpacing: CGFloat = 16
    
    private static let defaultSheetFraction: CGFloat = 0.12
    private static let additionalSheetItemFraction: CGFloat = 0.06
    static func sheetFraction(itemCount: Int) -> CGFloat {
        defaultSheetFraction + CGFloat(additionalSheetItemFraction * CGFloat(itemCount - 1))
    }
    static func reportSheetFraction(itemCount: Int) -> CGFloat {
        defaultSheetFraction + CGFloat(additionalSheetItemFraction * CGFloat(itemCount))
    }
    static let sheetItemSpacing: CGFloat = 30
    
    static let chipPadding = PaddingValues(horizontal: smallPadding)
    static let chipMinHeight: CGFloat = 32
}
