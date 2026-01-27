import SwiftUI

struct PlainTableUIViewControllerRepresentable<
    Value: Hashable,
    Header: View,
    Content: View,
    EmptyContent: View
>: UIViewControllerRepresentable {
    typealias Controller = PlainTableUIViewController<Value, Header, Content, EmptyContent>
    typealias Modifier = PlainTableModifier<Value>
    
    let modifier: Modifier
    let values: [Value]
    let onRowClick: (Value) -> Void
    let header: (() -> Header)?
    let emptyContent: () -> EmptyContent
    let content: (Value) -> Content
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIViewController(context: Context) -> Controller {
        let controller = PlainTableUIViewController(
            modifier: modifier,
            onRowClick: onRowClick,
            header: header,
            emptyContent: emptyContent,
            content: content
        )
        controller.coordinator = context.coordinator
        context.coordinator.configure(controller)
        
        return controller
    }

    func updateUIViewController(_ controller: Controller, context: Context) {
        updateTableView(controller: controller, coordinator: context.coordinator)
        updateSnapshotIfNeeded(coordinator: context.coordinator)
    }
    
    private func updateTableView(controller: Controller, coordinator: Coordinator) {
        controller.tableView.allowsSelection = !values.isEmpty
        controller.tableView.separatorStyle = values.isEmpty ? .none : modifier.separatorStyle
        if let header {
            controller.makeHeader(header: header())
        }
        
    }
    
    private func updateSnapshotIfNeeded(coordinator: Coordinator) {
        if coordinator.values != values {
            coordinator.updateSnapshot(values)
        }
    }
    
    class Coordinator {
        private typealias DataSource = UITableViewDiffableDataSource<Int, TableItem>
        private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, TableItem>
        
        private var dataSource: DataSource!
        
        private(set) var values: [Value]? = nil
        
        func configure(_ controller: Controller) {
            dataSource = DataSource(
                tableView: controller.tableView,
                cellProvider: { tableView, indexPath, item in
                    switch item {
                        case .value:
                            controller.makePlainCell(tableView: tableView, indexPath: indexPath)
                        
                        case .empty:
                            controller.makeEmptyCell(tableView: tableView, indexPath: indexPath)
                    }
                }
            )
        }
        
        func updateSnapshot(_ values: [Value]) {
            self.values = values
            
            var snapshot = Snapshot()
            snapshot.appendSections([0])
            if values.isEmpty {
                snapshot.appendItems([.empty])
            } else {
                snapshot.appendItems(values.map { .value($0) })
            }
            
            dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    private enum TableItem: Hashable {
        case value(Value)
        case empty
    }
}
