import SwiftUI

struct TextIcon<Icon: View, Text: View>: View {
    let icon: () -> Icon
    let text: () -> Text
    
    var body: some View {
        HStack(alignment: .center, spacing: Dimens.extraSmallPadding) {
            icon()
            text()
        }
    }
}
