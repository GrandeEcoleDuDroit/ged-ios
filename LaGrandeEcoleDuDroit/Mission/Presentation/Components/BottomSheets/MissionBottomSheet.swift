import SwiftUI

struct MissionBottomSheet: View {
    let mission: Mission
    let editable: Bool
    let onDeleteClick: () -> Void
    
    var body: some View {
        switch mission.state {
            case .error: ErrorMissionBottomSheet(onDeleteClick: onDeleteClick)
            
            default:
                if editable {
                    BottomSheetContainer(fraction: 0.12) {
                        EditableAnnouncementBottomSheetContent(
                            onDeleteClick: onDeleteClick
                        )
                    }
                }
        }
    }
}

private struct ErrorMissionBottomSheet: View {
    let onDeleteClick: () -> Void
    
    var body: some View {
        BottomSheetContainer(fraction: 0.12) {
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
    let onDeleteClick: () -> Void
    
    var body: some View {
        ClickableTextItem(
            icon: Image(systemName: "trash"),
            text: Text(stringResource(.delete)),
            onClick: onDeleteClick
        )
        .foregroundColor(.red)
    }
}
