import SwiftUI

private let plainTableViewIdentifier: String = "plainTableViewCell"

class PlainTableViewController<Value, Content: View, Cell: PlainTableViewCell>: UITableViewController {
    private let values: [Value]
    private let getIdentifier: (Value) -> Int
    private let onRowTap: (Value) -> Void
    private let content: (Value) -> Content
    
    private var onLongPress: ((Value) -> Void)?
    private var onRefresh: (() async -> Void)?
        
    init(
        values: [Value],
        getIdentifier: @escaping (Value) -> Int,
        onRowTap: @escaping (Value) -> Void,
        content: @escaping (Value) -> Content
    ) {
        self.values = values
        self.getIdentifier = getIdentifier
        self.onRowTap = onRowTap
        self.content = content
        
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        tableView.register(PlainTableViewCell.self, forCellReuseIdentifier: plainTableViewIdentifier)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        if onRefresh != nil {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(
                self,
                action: #selector(handleRefresh),
                for: .valueChanged
            )
            tableView.refreshControl = refreshControl
        }
        
        if onLongPress != nil {
            let longPressRecognizer = UILongPressGestureRecognizer(
                target: self,
                action: #selector(handleLongPress)
            )
            longPressRecognizer.cancelsTouchesInView = false
            tableView.addGestureRecognizer(longPressRecognizer)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        values.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: plainTableViewIdentifier, for: indexPath) as! Cell
        let value = values[indexPath.row]
        cell.tag = getIdentifier(value)
        cell.hostingController.setView {
            content(value)
                .allowsHitTesting(true)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onRowTap(values[indexPath.row])
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }

        guard let tableView = gesture.view as? UITableView else { return }
        let point = gesture.location(in: tableView)

        if let indexPath = tableView.indexPathForRow(at: point) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            onLongPress?(values[indexPath.row])
        }
    }
    
    @objc func handleRefresh(_ sender: UIRefreshControl) {
        Task {
            await onRefresh?()
            await MainActor.run {
                sender.endRefreshing()
            }
        }
    }
}

class PlainTableViewCell: UITableViewCell {
    var hostingController: UIHostingController<AnyView>
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        hostingController = UIHostingController(rootView: AnyView(EmptyView()))
       
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        hostingController.view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
        backgroundColor = .clear
        selectionStyle = .default
    }
        
    required init?(coder: NSCoder) { fatalError() }
}

extension PlainTableViewController {
    func onLongPress(_ action: @escaping (Value) -> Void) -> Self {
        let copy = self
        copy.onLongPress = action
        return copy
    }
    
    func onRefresh(_ action: @escaping () async -> Void) -> Self {
        let copy = self
       copy.onRefresh = action
       return copy
   }
    
    func tableBackground(_ color: Color) -> Self {
        let copy = self
        copy.tableView.backgroundColor = UIColor(color)
        return copy
    }
}
