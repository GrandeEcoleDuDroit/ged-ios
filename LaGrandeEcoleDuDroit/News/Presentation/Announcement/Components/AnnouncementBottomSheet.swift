import SwiftUI

struct AnnouncementBottomSheet: View {
    let announcement: Announcement
    let isEditable: Bool
    let onEditClick: () -> Void
    let onResendClick: () -> Void
    let onDeleteClick: () -> Void
    let onReportClick: () -> Void
    
    var body: some View {
        switch announcement.state {
            case .error:
                ErrorAnnouncementBottomSheet(
                    onResendClick: onResendClick,
                    onDeleteClick: onDeleteClick
                )
                
            default:
                if isEditable {
                    BottomSheetContainer(fraction: Dimens.bottomSheetFraction(itemCount: 2)) {
                        EditableAnnouncementBottomSheetContent(
                            onEditClick: onEditClick,
                            onDeleteClick: onDeleteClick
                        )
                    }
                } else {
                    BottomSheetContainer(fraction: Dimens.bottomSheetFraction(itemCount: 1)) {
                        NonEditableAnnouncementBottomSheetContent(
                            onReportClick: onReportClick
                        )
                    }
                }
        }
    }
}

private struct ErrorAnnouncementBottomSheet: View {
    let onResendClick: () -> Void
    let onDeleteClick: () -> Void
    
    var body: some View {
        BottomSheetContainer(fraction: Dimens.bottomSheetFraction(itemCount: 2)) {
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

private struct EditableAnnouncementBottomSheetContent: View {
    let onEditClick: () -> Void
    let onDeleteClick: () -> Void
    
    var body: some View {
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

private struct NonEditableAnnouncementBottomSheetContent: View {
    let onReportClick: () -> Void
    
    var body: some View {
        ClickableTextItem(
            icon: Image(systemName: "exclamationmark.bubble"),
            text: Text(stringResource(.report)),
            onClick: onReportClick
        )
        .foregroundColor(.red)
    }
}

#Preview {
    AnnouncementBottomSheet(
        announcement: announcementFixture,
        isEditable: true,
        onEditClick: {},
        onResendClick: {},
        onDeleteClick: {},
        onReportClick: {}
    )
}
