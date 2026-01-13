import SwiftUI
import Combine

struct PlainTableView<
    Value: Hashable,
    Content: View,
    EmptyContent: View
>: View {
    var modifier: PlainTableModifier<Value> = .init()
    let values: [Value]
    let onRowClick: (Value) -> Void
    @ViewBuilder let emptyContent: () -> EmptyContent
    @ViewBuilder let content: (Value) -> Content
    
    var body: some View {
        PlainTableUIViewControllerRepresentable(
            modifier: modifier,
            values: values,
            onRowClick: onRowClick,
            emptyContent: emptyContent,
            content: content
        )
        .ignoresSafeArea(.all)
    }
}

#Preview {
    NavigationStack {
        PlainTableView(
            values: Array(0..<50),
            onRowClick: { _ in },
            emptyContent: {}
        ) { number in
            Text(number.description)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
