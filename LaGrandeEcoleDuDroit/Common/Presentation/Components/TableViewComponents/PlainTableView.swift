import SwiftUI

struct PlainTableView<Value: Identifiable, Content: View>: View {
    private let values: [Value]
    private let onRowTap: (Value) -> Void
    private let content: (Value) -> Content
    
    private var navigationTitle: String?
    private var onLongPress: ((Value) -> Void)?
    private var allowInnerClick: Bool = false
    private var onRefresh: (() async -> Void)?
    private var tableBackground: Color?
    private var rightBarButtonItems: [UIBarButtonItem]?
    
    init(
        _ values: [Value],
        onRowTap: @escaping (Value) -> Void,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.values = values
        self.onRowTap = onRowTap
        self.content = content
    }
    
    var body: some View {
        PlainTableViewRepresentable(
            values: values,
            getIdentifier: { $0.id.hashValue },
            navigationTitle: navigationTitle,
            onRowTap: onRowTap,
            content: content,
            onLongPress: onLongPress,
            allowHitTesting: allowInnerClick,
            onRefresh: onRefresh,
            background: tableBackground,
            rightBarButtonItems: rightBarButtonItems
        )
        .ignoresSafeArea()
    }
}

private struct PlainTableViewRepresentable<T, Content: View, Cell: PlainTableViewCell>: UIViewControllerRepresentable {
    let values: [T]
    let getIdentifier: (T) -> Int
    let navigationTitle: String?
    let onRowTap: (T) -> Void
    let content: (T) -> Content
    let onLongPress: ((T) -> Void)?
    let allowHitTesting: Bool
    let onRefresh: (() async  -> Void)?
    let background: Color?
    let rightBarButtonItems: [UIBarButtonItem]?
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = PlainTableViewController(
            values: values,
            getIdentifier: getIdentifier,
            onRowTap: onRowTap,
            content: content
        )
        
        controller.title = navigationTitle
        controller.navigationController?.navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: false)
        
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

extension PlainTableView {
    func onLongPress(_ action: @escaping (Value) -> Void) -> Self {
        var copy = self
        copy.onLongPress = action
        return copy
    }
    
    func onRefresh(_ action: @escaping () async -> Void) -> Self {
       var copy = self
       copy.onRefresh = action
       return copy
   }
    
    func tableBackground(_ color: Color) -> Self {
        var copy = self
        copy.tableBackground = color
        return copy
    }
    
    func allowInnerClick(_ allowInnerClick: Bool) -> Self {
        var copy = self
        copy.allowInnerClick = allowInnerClick
        return copy
    }
    
    func rightBarButtonItems(_ buttonItems: [UIBarButtonItem]) -> Self {
        var copy = self
        copy.rightBarButtonItems = buttonItems
        return copy
    }
    
    func tableNavigationTitle(_ title: String) -> Self {
        var copy = self
        copy.navigationTitle = title
        return copy
    }
}

#Preview {
    PlainTableView(
        usersFixture,
        onRowTap: { _ in }
    ) { user in
        HStack(spacing: Dimens.mediumPadding) {
            Image(systemName: "person")
            
            Text(user.fullName)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: "chevron.right")
        }
        .padding()
    }
}
