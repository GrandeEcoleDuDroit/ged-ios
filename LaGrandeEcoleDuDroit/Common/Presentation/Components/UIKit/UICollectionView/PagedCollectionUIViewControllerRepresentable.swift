import SwiftUI

struct PagedCollectionUIViewControllerRepresentable<
    Value: Hashable,
    Content: View
>: UIViewControllerRepresentable {
    typealias Controller = PagedCollectionUIViewController<Value, Content>
    
    @Binding var state: PaginationState
    let values: [Value]
    let onCellClick: (Value) -> Void
    let content: (Value) -> Content
    
    init(
        state: Binding<PaginationState>,
        values: [Value],
        onCellClick: @escaping (Value) -> Void,
        content: @escaping (Value) -> Content
    ) {
        self._state = state
        self.values = values
        self.onCellClick = onCellClick
        self.content = content
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIViewController(context: Context) -> Controller {
        let controller = PagedCollectionUIViewController(
            state: $state,
            onCellClick: onCellClick,
            content: content
        )
        controller.coordinator = context.coordinator
        context.coordinator.configure(controller)
        return controller
    }
    
    func updateUIViewController(_ controller: Controller, context: Context) {
        updateSnapshotIfNeeded(coordinator: context.coordinator)
    }
    
    private func updateSnapshotIfNeeded(coordinator: Coordinator) {
        if coordinator.values != values {
            coordinator.updateSnapshot(values)
        }
    }
    
    class Coordinator {
        private typealias DataSource = UICollectionViewDiffableDataSource<Int, Value>
        private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Value>

        private var dataSource: DataSource!
        
        private(set) var values: [Value]? = nil
        
        func configure(_ controller: Controller) {
            dataSource = DataSource(
                collectionView: controller.collectionView,
                cellProvider: { collectionView, indexPath, _ in
                    controller.makePagingCell(collectionView: collectionView, indexPath: indexPath)
                }
            )
        }
        
        func updateSnapshot(_ values: [Value]) {
            self.values = values
            var snapshot = Snapshot()
            snapshot.appendSections([0])
            snapshot.appendItems(values)
            dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
}
