import SwiftUI

struct MenuItem: View {
    private let icon: Image
    private let title: String
    private let color: Color
    
    init(
        icon: Image,
        title: String,
        color: Color = .accentColor
    ) {
        self.icon = icon
        self.title = title
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: GedSpacing.smallMedium) {
            icon
            Text(title)
        }
        .foregroundStyle(color)
    }
}

#Preview {
    List {
        MenuItem(
            icon: Image(systemName: "person.fill"),
            title: getString(.accountInfos)
        )
    }
}
