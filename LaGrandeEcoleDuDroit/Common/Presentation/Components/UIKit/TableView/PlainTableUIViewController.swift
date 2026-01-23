import SwiftUI

class PlainTableUIViewController<
    Value: Hashable,
    Header: View,
    Content: View,
    EmptyContent: View
>: UITableViewController {
    let modifier: PlainTableModifier<Value>
    private let onRowClick: (Value) -> Void
    private let header: (() -> Header)?
    private let emptyContent: () -> EmptyContent
    private let content: (Value) -> Content
    
    weak var coordinator: PlainTableUIViewControllerRepresentable<Value, Header, Content, EmptyContent>.Coordinator?

    init(
        modifier: PlainTableModifier<Value>,
        onRowClick: @escaping (Value) -> Void,
        header: (() -> Header)?,
        emptyContent: @escaping () -> EmptyContent,
        content: @escaping (Value) -> Content,
    ) {
        self.modifier = modifier
        self.onRowClick = onRowClick
        self.header = header
        self.content = content
        self.emptyContent = emptyContent
        
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        if let header {
            let frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 48)
            tableView.tableHeaderView = PlainTableViewHeader(frame: frame, header: header())
        }
        tableView.register(PlainTableViewCell.self, forCellReuseIdentifier: PlainTableViewCell.plainCellIdentifier)
        tableView.register(PlainTableViewCell.self, forCellReuseIdentifier: PlainTableViewCell.emptyCellIdentifier)
        tableView.separatorStyle = modifier.separatorStyle
        tableView.backgroundColor = UIColor(modifier.backgroundColor)
        
        if modifier.onRefresh != nil {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
            tableView.refreshControl = refreshControl
        }
        
        if modifier.onRowLongClick != nil {
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
            longPressRecognizer.cancelsTouchesInView = false
            tableView.addGestureRecognizer(longPressRecognizer)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        coordinator?.values?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        makePlainCell(tableView: tableView, indexPath: indexPath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let value = coordinator?.values?[indexPath.row] {
            onRowClick(value)
        }
    }
    
    func makePlainCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let value = coordinator?.values?[indexPath.row] else {
           return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PlainTableViewCell.plainCellIdentifier, for: indexPath) as! PlainTableViewCell
        cell.tag = value.hashValue
        cell.selectionStyle = modifier.selectionStyle
        cell.set { content(value).allowsHitTesting(true) }
        return cell
    }
    
    func makeEmptyCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlainTableViewCell.emptyCellIdentifier, for: indexPath) as! PlainTableViewCell
        cell.selectionStyle = .none
        cell.set {
            emptyContent()
                .padding()
                .allowsHitTesting(true)
        }
        return cell
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, let tableView = gesture.view as? UITableView else { return }
        
        let point = gesture.location(in: tableView)
        
        if let indexPath = tableView.indexPathForRow(at: point),
           let value = coordinator?.values?[indexPath.row],
           let onRowLongClick = modifier.onRowLongClick
        {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            onRowLongClick(value)
        }
    }
    
    @objc func handleRefresh(_ sender: UIRefreshControl) {
        Task {
            await modifier.onRefresh?()
            await MainActor.run {
                sender.endRefreshing()
            }
        }
    }
}

private class PlainTableViewCell: UITableViewCell {
    private let hostingController = UIHostingController(rootView: AnyView(EmptyView()))
    static let emptyCellIdentifier = "EmptyCell"
    static let plainCellIdentifier = "PlainCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
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

private class PlainTableViewHeader<Header: View>: UIView {
    init(frame: CGRect, header: Header) {
        super.init(frame: frame)
        
        let hostingController = UIHostingController(rootView: header)
        let hostedView = hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        hostedView.backgroundColor = .clear
        hostedView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        addSubview(hostedView)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
