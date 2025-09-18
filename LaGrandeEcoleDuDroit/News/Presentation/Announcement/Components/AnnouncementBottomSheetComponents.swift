import SwiftUI

struct AnnouncementBottomSheet: View {
    let isEditable: Bool
    let onEditClick: () -> Void
    let onDeleteClick: () -> Void
    let onReportClick: () -> Void
    
    var body: some View {
        if isEditable {
            BottomSheetContainer(fraction: 0.16) {
                EditableAnnouncementBottomSheetContent(
                    onEditClick: onEditClick,
                    onDeleteClick: onDeleteClick
                )
            }
        } else {
            BottomSheetContainer(fraction: 0.1) {
                NonEditableAnnouncementBottomSheetContent(
                    onReportClick: onReportClick
                )
            }
        }
        
    }
}

struct ErrorAnnouncementBottomSheet: View {
    let onResendClick: () -> Void
    let onDeleteClick: () -> Void
    
    var body: some View {
        BottomSheetContainer(fraction: 0.16) {
            ClickableTextItem(
                icon: Image(systemName: "paperplane"),
                text: Text(getString(.resend)),
                onClick: onResendClick
            )
            
            ClickableTextItem(
                icon: Image(systemName: "trash"),
                text: Text(getString(.delete)),
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
            text: Text(getString(.edit)),
            onClick: onEditClick
        )
        
        ClickableTextItem(
            icon: Image(systemName: "trash"),
            text: Text(getString(.delete)),
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
            text: Text(getString(.report)),
            onClick: onReportClick
        )
        .foregroundColor(.red)
    }
}

#Preview {
    ZStack {}
        .sheet(isPresented: .constant(true)) {
            AnnouncementBottomSheet(
                isEditable: true,
                onEditClick: {},
                onDeleteClick: {},
                onReportClick: {}
            )
        }
}
