import SwiftUI

struct PagedCollectionView<
    Value: Hashable,
    Content: View
>: View {
    @Binding var state: PaginationState
    let values: [Value]
    let onCellClick: (Value) -> Void
    @ViewBuilder let content: (Value) -> Content
    
    init(
        state: Binding<PaginationState> = .constant(PaginationState()),
        values: [Value],
        onCellClick: @escaping (Value) -> Void,
        content: @escaping (Value) -> Content
    ) {
        self._state = state
        self.values = values
        self.onCellClick = onCellClick
        self.content = content
    }

    var body: some View {
        PagedCollectionUIViewControllerRepresentable(
            state: $state,
            values: values,
            onCellClick: onCellClick,
            content: content
        )
    }
}

#Preview {
    PagedCollectionView(
        state: .constant(PaginationState()),
        values: Array(0..<50),
        onCellClick: { _ in }
    ) { value in
        Text(value.description)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: (10 * Double(value) / 255), green: (20 * Double(value) / 255), blue: (40 * Double(value) / 255)))
    }
}
