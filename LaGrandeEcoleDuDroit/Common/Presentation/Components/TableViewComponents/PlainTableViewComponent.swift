import SwiftUI

fileprivate let plainTableViewIdentifier: String = "plainTableViewCell"

struct PlainTableView<Cell: PlainTableViewCell, T>: UIViewControllerRepresentable {
    let items: [T]
    let configureCell: (Cell, T) -> Void
    
    init(
        items: [T],
        configureCell: @escaping (PlainTableViewCell, T) -> Void
    ) {
        self.items = items
        self.configureCell = configureCell
    }
    
    func makeUIViewController(context: Context) -> UITableViewController {
        let controller = UITableViewController(style: .plain)
        controller.tableView.register(PlainTableViewCell.self, forCellReuseIdentifier: plainTableViewIdentifier)
        controller.tableView.delegate = context.coordinator
        controller.tableView.dataSource = context.coordinator
        controller.tableView.backgroundColor = .clear
        controller.tableView.separatorStyle = .none
        return controller
    }

    func updateUIViewController(_ uiViewController: UITableViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(items: items, configureCell: configureCell)
    }

    class Coordinator: NSObject, UITableViewDelegate, UITableViewDataSource {
        let items: [T]
        let configureCell: (Cell, T) -> Void

        init(items: [T], configureCell: @escaping (Cell, T) -> Void) {
            self.items = items
            self.configureCell = configureCell
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            items.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: plainTableViewIdentifier, for: indexPath) as! Cell
            cell.tag = indexPath.row
            configureCell(cell, items[indexPath.row])
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            print("Selected row \(indexPath.row)")
        }
    }
}

class PlainTableViewCell: UITableViewCell {
    var leadingHosting: UIHostingController<AnyView>
    var contentHosting: UIHostingController<AnyView>
    var trailingHosting: UIHostingController<AnyView>
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        leadingHosting = UIHostingController(rootView: AnyView(EmptyView()))
        contentHosting = UIHostingController(rootView: AnyView(EmptyView()))
        trailingHosting = UIHostingController(rootView: AnyView(EmptyView()))
       
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        [leadingHosting, contentHosting, trailingHosting].forEach {
            $0.view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0.view)
            $0.view.backgroundColor = .clear
        }
        
        NSLayoutConstraint.activate([
            leadingHosting.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Dimens.mediumPadding),
            leadingHosting.view.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            contentHosting.view.leadingAnchor.constraint(equalTo: leadingHosting.view.trailingAnchor, constant: Dimens.mediumPadding),
            contentHosting.view.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                        
            trailingHosting.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Dimens.mediumPadding),
            trailingHosting.view.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        leadingHosting.view.setContentHuggingPriority(.required, for: .horizontal)
        contentHosting.view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        trailingHosting.view.setContentHuggingPriority(.required, for: .horizontal)
        
    
        backgroundColor = .clear
        selectionStyle = .default
    }
        
    required init?(coder: NSCoder) { fatalError() }
}

#Preview {
    PlainTableView(items: [1,2,3]) { cell, value in
        cell.leadingHosting.setView { Image(systemName: "person") }
        cell.contentHosting.setView { Text("\(value)") }
        cell.trailingHosting.setView { Image(systemName: "chevron.right") }
    }
    .background(Color.background)    
}
