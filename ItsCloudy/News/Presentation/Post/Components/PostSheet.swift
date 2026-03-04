import SwiftUI

struct PostSheet: View {
    let postState: Post.PostState
    let editable: Bool
    let onEditClick: () -> Void
    let onRecreateClick: () -> Void
    let onDeleteClick: () -> Void
    let onReportClick: () -> Void
    
    init(
        postState: Post.PostState,
        editable: Bool,
        onEditClick: @escaping () -> Void,
        onRecreateClick: @escaping () -> Void = {},
        onDeleteClick: @escaping () -> Void,
        onReportClick: @escaping () -> Void
    ) {
        self.postState = postState
        self.editable = editable
        self.onEditClick = onEditClick
        self.onRecreateClick = onRecreateClick
        self.onDeleteClick = onDeleteClick
        self.onReportClick = onReportClick
    }
    
    var body: some View {
        switch postState {
            case .published:
                PublishedPostSheet(
                    editable: editable,
                    onEditClick: onEditClick,
                    onDeleteClick: onDeleteClick,
                    onReportClick: onReportClick
                )
                
            case .publishing:
                PublishingPostSheet(onDeleteClick: onDeleteClick)
                
            case .error:
                ErrorPostSheet(
                    onRecreateClick: onRecreateClick,
                    onDeleteClick: onDeleteClick
                )
                
            default: EmptyView()
        }
    }
}

private struct PublishedPostSheet: View {
    let editable: Bool
    let onEditClick: () -> Void
    let onDeleteClick: () -> Void
    let onReportClick: () -> Void
    
    var body: some View {
        if editable {
            SheetContainer(fraction: DimensResource.sheetFraction(itemCount: 2)) {
                SheetItem(
                    icon: Image(systemName: "pencil"),
                    text: stringResource(.edit),
                    onClick: onEditClick
                )
                
                SheetItem(
                    icon: Image(systemName: "trash"),
                    text: stringResource(.delete),
                    onClick: onDeleteClick
                )
                .foregroundColor(.red)
            }
        } else {
            SheetContainer(fraction: DimensResource.sheetFraction(itemCount: 1)) {
                SheetItem(
                    icon: Image(systemName: "exclamationmark.bubble"),
                    text: stringResource(.report),
                    onClick: onReportClick
                )
                .foregroundColor(.red)
            }
        }
    }
}

private struct PublishingPostSheet: View {
    let onDeleteClick: () -> Void

    var body: some View {
        SheetContainer(fraction: DimensResource.sheetFraction(itemCount: 1)) {
            SheetItem(
                icon: Image(systemName: "trash"),
                text: stringResource(.delete),
                onClick: onDeleteClick
            )
            .foregroundColor(.red)
        }
    }
}

private struct ErrorPostSheet: View {
    let onRecreateClick: () -> Void
    let onDeleteClick: () -> Void
    
    var body: some View {
        SheetContainer(fraction: DimensResource.sheetFraction(itemCount: 2)) {
            SheetItem(
                icon: Image(systemName: "arrow.clockwise"),
                text: stringResource(.retry),
                onClick: onRecreateClick
            )
            
            SheetItem(
                icon: Image(systemName: "trash"),
                text: stringResource(.delete),
                onClick: onDeleteClick
            )
            .foregroundColor(.red)
        }
    }
}

#Preview {
    PostSheet(
        postState: postFixture.state,
        editable: true,
        onEditClick: {},
        onRecreateClick: {},
        onDeleteClick: {},
        onReportClick: {}
    )
}

