import SwiftUI

struct AnnouncementSheet: View {
    let announcement: Announcement
    let isEditable: Bool
    let onEditClick: () -> Void
    let onResendClick: () -> Void
    let onDeleteClick: () -> Void
    let onReportClick: () -> Void
    
    var body: some View {
        switch announcement.state {
            case .error:
                ErrorAnnouncementSheet(
                    onResendClick: onResendClick,
                    onDeleteClick: onDeleteClick
                )
                
            default:
                if isEditable {
                    EditableAnnouncementSheet(
                        onEditClick: onEditClick,
                        onDeleteClick: onDeleteClick
                    )
                } else {
                    NonEditableAnnouncementSheet(
                        onReportClick: onReportClick
                    )
                }
        }
    }
}

private struct ErrorAnnouncementSheet: View {
    let onResendClick: () -> Void
    let onDeleteClick: () -> Void
    
    var body: some View {
        SheetContainer(fraction: Dimens.sheetFraction(itemCount: 2)) {
            ClickableTextItem(
                icon: Image(systemName: "paperplane"),
                text: Text(stringResource(.resend)),
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

private struct EditableAnnouncementSheet: View {
    let onEditClick: () -> Void
    let onDeleteClick: () -> Void
    
    var body: some View {
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
    }
}

private struct NonEditableAnnouncementSheet: View {
    let onReportClick: () -> Void
    
    var body: some View {
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

#Preview {
    AnnouncementSheet(
        announcement: announcementFixture,
        isEditable: true,
        onEditClick: {},
        onResendClick: {},
        onDeleteClick: {},
        onReportClick: {}
    )
}
