import SwiftUI
import Combine

struct PlainTableView<
    Value: Hashable,
    Header: View,
    Content: View,
    EmptyContent: View
>: View {
    var modifier: PlainTableModifier<Value>
    let values: [Value]
    let onRowClick: (Value) -> Void
    @ViewBuilder let header: (() -> Header)?
    @ViewBuilder let emptyContent: () -> EmptyContent
    @ViewBuilder let content: (Value) -> Content
    
    init(
        values: [Value],
        onRowClick: @escaping (Value) -> Void,
        emptyContent: @escaping () -> EmptyContent,
        content: @escaping (Value) -> Content
    ) where Header == Never {
        self.modifier = .init()
        self.values = values
        self.onRowClick = onRowClick
        self.header = nil
        self.emptyContent = emptyContent
        self.content = content
    }
    
    var body: some View {
        PlainTableUIViewControllerRepresentable(
            modifier: modifier,
            values: values,
            onRowClick: onRowClick,
            header: header,
            emptyContent: emptyContent,
            content: content
        )
        .ignoresSafeArea(.all)
    }
}

extension PlainTableView {
    init(
        modifier: PlainTableModifier<Value> = .init(),
        values: [Value],
        onRowClick: @escaping (Value) -> Void,
        emptyContent: @escaping () -> EmptyContent,
        content: @escaping (Value) -> Content
    ) where Header == Never {
        self.modifier = modifier
        self.values = values
        self.onRowClick = onRowClick
        self.header = nil
        self.emptyContent = emptyContent
        self.content = content
    }
    
    init(
        modifier: PlainTableModifier<Value> = .init(),
        values: [Value],
        onRowClick: @escaping (Value) -> Void,
        header: @escaping () -> Header,
        emptyContent: @escaping () -> EmptyContent,
        content: @escaping (Value) -> Content
    ) {
        self.modifier = modifier
        self.values = values
        self.onRowClick = onRowClick
        self.header = header
        self.emptyContent = emptyContent
        self.content = content
    }
}

#Preview {
    NavigationStack {
        PlainTableView(
            values: Array(0..<50),
            onRowClick: { _ in },
            emptyContent: { EmptyView() }
        ) { number in
            Text(number.description)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
