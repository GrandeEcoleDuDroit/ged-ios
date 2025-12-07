import SwiftUI

struct MissionBottomSheet: View {
    let mission: Mission
    let isAdminUser: Bool
    let onEditClick: () -> Void
    let onDeleteClick: () -> Void
    let onReportClick: () -> Void
    
    var body: some View {
        switch mission.state {
            case .error: ErrorMissionBottomSheet(onDeleteClick: onDeleteClick)
            
            default:
                if isAdminUser {
                    EditableMissionBottomSheet(
                        onEditClick: onEditClick,
                        onDeleteClick: onDeleteClick
                    )
                } else {
                    NonEditableMissionBottomSheet(onReportClick: onReportClick)
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

private struct EditableMissionBottomSheet: View {
    let onEditClick: () -> Void
    let onDeleteClick: () -> Void
    
    var body: some View {
        BottomSheetContainer(fraction: Dimens.bottomSheetFraction(itemCount: 2)) {
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

private struct NonEditableMissionBottomSheet: View {
    let onReportClick: () -> Void
    
    var body: some View {
        BottomSheetContainer(fraction: Dimens.bottomSheetFraction(itemCount: 1)) {
            ClickableTextItem(
                icon: Image(systemName: "exclamationmark.bubble"),
                text: Text(stringResource(.report)),
                onClick: onReportClick
            )
            .foregroundColor(.red)
        }
    }
}
