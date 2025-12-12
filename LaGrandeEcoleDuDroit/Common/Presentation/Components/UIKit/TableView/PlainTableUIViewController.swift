import SwiftUI

class PlainTableUIViewController<
    Value: Hashable,
    Content: View,
    EmptyContent: View
>: UITableViewController {
    let modifier: PlainTableModifier<Value>
    var values: [Value]
    private let onRowClick: (Value) -> Void
    private let emptyContent: () -> EmptyContent
    private let content: (Value) -> Content
    
    init(
        modifier: PlainTableModifier<Value>,
        values: [Value],
        onRowClick: @escaping (Value) -> Void,
        emptyContent: @escaping () -> EmptyContent,
        content: @escaping (Value) -> Content,
    ) {
        self.modifier = modifier
        self.values = values
        self.onRowClick = onRowClick
        self.content = content
        self.emptyContent = emptyContent
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        tableView.register(PlainTableViewCell.self, forCellReuseIdentifier: PlainTableViewCell.plainCellIdentifier)
        tableView.register(PlainTableViewCell.self, forCellReuseIdentifier: PlainTableViewCell.emptyCellIdentifier)
        tableView.separatorStyle = .none
        tableView.allowsSelection = !values.isEmpty
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
        values.isEmpty ? 1 : values.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        configureCell(tableView: tableView, indexPath: indexPath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !values.isEmpty else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        onRowClick(values[indexPath.row])
    }
    
    func configureCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if values.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: PlainTableViewCell.emptyCellIdentifier, for: indexPath) as! PlainTableViewCell
            cell.set { emptyContent().allowsHitTesting(true) }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: PlainTableViewCell.plainCellIdentifier, for: indexPath) as! PlainTableViewCell
            let value = values[indexPath.row]
            cell.tag = value.hashValue
            cell.set { content(value).allowsHitTesting(true) }
            return cell
        }
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard !values.isEmpty,
              gesture.state == .began,
              let tableView = gesture.view as? UITableView
        else { return }
        
        let point = gesture.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            modifier.onRowLongClick?(values[indexPath.row])
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
        selectionStyle = .default
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

private enum SectionType {
   case main
}
