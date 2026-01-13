import SwiftUI

struct PlainTableModifier<Value> {
    let backgroundColor: Color
    let separatorStyle: UITableViewCell.SeparatorStyle
    let selectionStyle: UITableViewCell.SelectionStyle
    let onRefresh: (() async -> Void)?
    let onRowLongClick: ((Value) -> Void)?
    
    init(
        backgroundColor: Color = .clear,
        separatorStyle: UITableViewCell.SeparatorStyle = .none,
        selectionStyle: UITableViewCell.SelectionStyle = .default,
        onRefresh: (() async -> Void)? = nil,
        onRowLongClick: ((Value) -> Void)? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.separatorStyle = separatorStyle
        self.selectionStyle = selectionStyle
        self.onRefresh = onRefresh
        self.onRowLongClick = onRowLongClick
    }
}
