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
                    BottomSheetContainer(fraction: Dimens.bottomSheetFraction(itemCount: 1)) {
                        EditableAnnouncementBottomSheetContent(
                            onDeleteClick: onDeleteClick
                        )
                    }
                } else {
                    BottomSheetContainer(fraction: Dimens.bottomSheetFraction(itemCount: 1)) {
                        Text("TODO: report mission sheet item")
                    }
                }
        }
    }
}

private struct ErrorMissionBottomSheet: View {
    let onDeleteClick: () -> Void
    
    var body: some View {
        BottomSheetContainer(fraction: Dimens.bottomSheetFraction(itemCount: 1)) {
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
