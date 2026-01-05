import SwiftUI

struct SheetContainer<Content: View>: View {
    let fraction: CGFloat
    let content: Content
    
    init(
        fraction: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self.fraction = fraction
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 30) {
            content
        }
        .presentationDetents([.fraction(fraction)])
        .padding(.horizontal)
    }
}

struct ReportSheet<T: CustomStringConvertible>: View {
    let items: [T]
    let fraction: CGFloat
    let onReportClick: (T) -> Void
    
    init(
        items: [T],
        fraction: CGFloat = Dimens.reportSheetFraction(itemCount: 1),
        onReportClick: @escaping (T) -> Void
    ) {
        self.items = items
        self.onReportClick = onReportClick
        self.fraction = fraction
    }
    
    var body: some View {
        VStack(spacing: Dimens.largePadding) {
            Text(stringResource(.report))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
            
            SheetContainer(fraction: fraction) {
                ForEach(items.indices, id: \.self) { index in
                    SheetItem(
                        text: items[index].description,
                        onClick: { onReportClick(items[index]) }
                    )
                }
            }
        }
    }
}

struct SheetItem: View {
    let icon: Image?
    let text: String
    let onClick: () -> Void
    
    init(
        icon: Image? = nil,
        text: String,
        onClick: @escaping () -> Void
    ) {
        self.icon = icon
        self.text = text
        self.onClick = onClick
    }
    
    var body: some View {
        Button(
            action: onClick,
            label: {
                Group {
                    if let icon {
                        TextIcon(icon: icon, text: text)
                    } else {
                        Text(text)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        )
    }
}

#Preview {
    ReportSheet(
        items: ["Spam", "Inappropriate content", "Harassment"],
        onReportClick: { _ in }
    )
}
