import SwiftUI

struct Dimens {
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
    
    static let toolbarVerticalPadding: CGFloat = 10
    static let toolbarHorizontalPadding: CGFloat = 16
    static let toolbarItemSpacing: CGFloat = 16
    
    private static let defaultBottomSheetFraction: CGFloat = 0.12
    private static let additionalBottomSheetItemFraction: CGFloat = 0.06
    static func bottomSheetFraction(itemCount: Int) -> CGFloat {
        defaultBottomSheetFraction + CGFloat(additionalBottomSheetItemFraction * CGFloat(itemCount - 1))
    }
    static func titleBottomSheetFraction(itemCount: Int) -> CGFloat {
        defaultBottomSheetFraction + CGFloat(additionalBottomSheetItemFraction * CGFloat(itemCount))
    }
}
