import SwiftUI

struct PlainTableUIViewControllerRepresentable<
    Value: Hashable,
    Content: View,
    EmptyContent: View
>: UIViewControllerRepresentable {
    typealias Controller = PlainTableUIViewController<Value, Content, EmptyContent>
    typealias Modifier = PlainTableModifier<Value>
    
    let modifier: Modifier
    let values: [Value]
    let onRowClick: (Value) -> Void
    let emptyContent: () -> EmptyContent
    let content: (Value) -> Content
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIViewController(context: Context) -> Controller {
        let controller = PlainTableUIViewController(
            modifier: modifier,
            values: values,
            onRowClick: onRowClick,
            emptyContent: emptyContent,
            content: content
        )
        context.coordinator.configure(controller)
        return controller
    }

    func updateUIViewController(_ controller: Controller, context: Context) {
        let coordinator = context.coordinator
        updateTableView(tableView: controller.tableView, coordinator: coordinator)
        updateDataSource(coordinator: coordinator)
    }
    
    private func updateDataSource(coordinator: Coordinator) {
        if coordinator.values != values {
            coordinator.values = values
            coordinator.updateDataSource(values)
        }
    }
    
    private func updateTableView(tableView: UITableView, coordinator: Coordinator) {
        tableView.allowsSelection = !values.isEmpty
        tableView.separatorStyle = values.isEmpty ? .none : modifier.separatorStyle
    }
    
    class Coordinator {
        private typealias DataSource = UITableViewDiffableDataSource<Int, Value>
        private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Value>
        
        private var dataSource: DataSource!
        
        var values: [Value] = []
        
        func configure(_ controller: Controller) {
            dataSource = DataSource(
                tableView: controller.tableView,
                cellProvider: { (tableView, indexPath, title) -> UITableViewCell? in
                    controller.configureCell(tableView: tableView, indexPath: indexPath)
                }
            )
        }
        
        func updateDataSource(_ values: [Value]) {
            var snapshot = Snapshot()
            snapshot.appendSections([0])
            snapshot.appendItems(values)
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}
