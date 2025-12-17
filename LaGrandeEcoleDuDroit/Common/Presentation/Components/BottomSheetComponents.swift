import SwiftUI

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
                .font(.titleMedium)
                .frame(maxWidth: .infinity, alignment: .center)
            
            SheetContainer(fraction: fraction) {
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
    ReportSheet(
        items: ["Spam", "Inappropriate content", "Harassment"],
        onReportClick: { _ in }
    )
}
