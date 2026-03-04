import SwiftUI

class PagedCollectionUIViewController<
    Value: Hashable,
    Content: View
>: UICollectionViewController {
    @Binding private var state: PaginationState
    private let onCellClick: (Value) -> Void
    private let content: (Value) -> Content
    
    weak var coordinator: PagedCollectionUIViewControllerRepresentable<Value, Content>.Coordinator?

    init(
        state: Binding<PaginationState>,
        onCellClick: @escaping (Value) -> Void,
        content: @escaping (Value) -> Content
    ) {
        self._state = state
        self.onCellClick = onCellClick
        self.content = content
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.register(PagingCollectionViewCell.self, forCellWithReuseIdentifier: PagingCollectionViewCell.identifier)
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, contentOffset, environment in
            let pageWidth = environment.container.contentSize.width
            let currentPage = Int(round(contentOffset.x / pageWidth))
            
            guard self?.state.currentPage != currentPage else { return }

            DispatchQueue.main.async {
                self?.state.currentPage = currentPage
            }
        }
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        coordinator?.values?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        makePagingCell(collectionView: collectionView, indexPath: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let value = coordinator?.values?[indexPath.row] {
            onCellClick(value)
        }
    }
    
    func makePagingCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let value = coordinator?.values?[indexPath.row] else {
            return UICollectionViewCell()
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PagingCollectionViewCell.identifier, for: indexPath) as! PagingCollectionViewCell
        cell.tag = value.hashValue
        cell.set { content(value).allowsHitTesting(true) }
        return cell
    }
}

private class PagingCollectionViewCell: UICollectionViewCell {
    private let hostingController = UIHostingController(rootView: AnyView(EmptyView()))
    static let identifier = "PagingCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
        let hostedView = hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        hostedView.backgroundColor = .clear
        hostedView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        contentView.addSubview(hostedView)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set<V: View>(_ builder: () -> V) {
        hostingController.rootView = AnyView(builder())

        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        hostingController.view.invalidateIntrinsicContentSize()

        setNeedsLayout()
        layoutIfNeeded()
    }
}
