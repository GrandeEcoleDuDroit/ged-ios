import SwiftUI

struct PlainTableModifier<Value> {
    let backgroundColor: Color
    let separatorStyle: UITableViewCell.SeparatorStyle
    let onRefresh: (() async -> Void)?
    let onRowLongClick: ((Value) -> Void)?
    
    init(
        backgroundColor: Color = .clear,
        separatorStyle: UITableViewCell.SeparatorStyle = .none,
        onRefresh: (() async -> Void)? = nil,
        onRowLongClick: ((Value) -> Void)? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.separatorStyle = separatorStyle
        self.onRefresh = onRefresh
        self.onRowLongClick = onRowLongClick
    }
}
