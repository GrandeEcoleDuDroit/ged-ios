import SwiftUI

struct AnnouncementSheet: View {
    let announcementState: Announcement.AnnouncementState
    let editable: Bool
    let onEditClick: () -> Void
    let onResendClick: () -> Void
    let onDeleteClick: () -> Void
    let onReportClick: () -> Void
    
    init(
        announcementState: Announcement.AnnouncementState,
        editable: Bool,
        onEditClick: @escaping () -> Void,
        onResendClick: @escaping () -> Void = {},
        onDeleteClick: @escaping () -> Void,
        onReportClick: @escaping () -> Void
    ) {
        self.announcementState = announcementState
        self.editable = editable
        self.onEditClick = onEditClick
        self.onResendClick = onResendClick
        self.onDeleteClick = onDeleteClick
        self.onReportClick = onReportClick
    }
    
    var body: some View {
        switch announcementState {
            case .published:
                PublishedAnnouncementSheet(
                    editable: editable,
                    onEditClick: onEditClick,
                    onDeleteClick: onDeleteClick,
                    onReportClick: onReportClick
                )
                
            case .publishing:
                PublishingAnnouncementSheet(onDeleteClick: onDeleteClick)
                
            case .error:
                ErrorAnnouncementSheet(
                    onResendClick: onResendClick,
                    onDeleteClick: onDeleteClick
                )
                
            default: EmptyView()
        }
    }
}

private struct PublishedAnnouncementSheet: View {
    let editable: Bool
    let onEditClick: () -> Void
    let onDeleteClick: () -> Void
    let onReportClick: () -> Void
    
    var body: some View {
        if editable {
            SheetContainer(fraction: Dimens.sheetFraction(itemCount: 2)) {
                ClickableTextItem(
                    icon: Image(systemName: "pencil"),
                    text: Text(stringResource(.edit)),
                    onClick: onEditClick
                )
                
                ClickableTextItem(
                    icon: Image(systemName: "trash"),
                    text: Text(stringResource(.delete)),
                    onClick: onDeleteClick
                )
                .foregroundColor(.red)
            }
        } else {
            SheetContainer(fraction: Dimens.sheetFraction(itemCount: 1)) {
                ClickableTextItem(
                    icon: Image(systemName: "exclamationmark.bubble"),
                    text: Text(stringResource(.report)),
                    onClick: onReportClick
                )
                .foregroundColor(.red)
            }
        }
    }
}

private struct PublishingAnnouncementSheet: View {
    let onDeleteClick: () -> Void

    var body: some View {
        SheetContainer(fraction: Dimens.sheetFraction(itemCount: 1)) {
            ClickableTextItem(
                icon: Image(systemName: "trash"),
                text: Text(stringResource(.delete)),
                onClick: onDeleteClick
            )
            .foregroundColor(.red)
        }
    }
}

private struct ErrorAnnouncementSheet: View {
    let onResendClick: () -> Void
    let onDeleteClick: () -> Void
    
    var body: some View {
        SheetContainer(fraction: Dimens.sheetFraction(itemCount: 2)) {
            ClickableTextItem(
                icon: Image(systemName: "arrow.clockwise"),
                text: Text(stringResource(.retry)),
                onClick: onResendClick
            )
            
            ClickableTextItem(
                icon: Image(systemName: "trash"),
                text: Text(stringResource(.delete)),
                onClick: onDeleteClick
            )
            .foregroundColor(.red)
        }
    }
}

#Preview {
    AnnouncementSheet(
        announcementState: announcementFixture.state,
        editable: true,
        onEditClick: {},
        onResendClick: {},
        onDeleteClick: {},
        onReportClick: {}
    )
}
