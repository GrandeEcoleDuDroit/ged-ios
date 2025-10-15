import SwiftUI

struct ReportBottomSheet<T: CustomStringConvertible>: View {
    let items: [T]
    let fraction: CGFloat
    let onReportClick: (T) -> Void
    
    init(
        items: [T],
        fraction: CGFloat = 0.1,
        onReportClick: @escaping (T) -> Void
    ) {
        self.items = items
        self.onReportClick = onReportClick
        self.fraction = fraction
    }
    
    var body: some View {
        VStack(spacing: GedSpacing.large) {
            Text(getString(.report))
                .font(.titleMedium)
                .frame(maxWidth: .infinity, alignment: .center)
            
            BottomSheetContainer(fraction: fraction) {
                ForEach(items.indices, id: \.self) { index in
                    ClickableTextItem(
                        text: Text(items[index].description),
                        onClick: { onReportClick(items[index]) }
                    )
                }
            }
        }
    }
}

#Preview {
    ReportBottomSheet(
        items: ["Spam", "Inappropriate content", "Harassment"],
        fraction: 0.5,
        onReportClick: { print($0) }
    )
    
    OptionButton(action: {})
}
