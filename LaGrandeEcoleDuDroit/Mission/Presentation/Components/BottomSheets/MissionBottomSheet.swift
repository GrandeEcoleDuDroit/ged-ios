import SwiftUI

struct MissionBottomSheet: View {
    let mission: Mission
    let isAdminUser: Bool
    let onEditClick: () -> Void
    let onDeleteClick: () -> Void
    let onReportClick: () -> Void
    let onResendClick: () -> Void
    
    init(
        mission: Mission,
        isAdminUser: Bool,
        onEditClick: @escaping () -> Void,
        onDeleteClick: @escaping () -> Void,
        onReportClick: @escaping () -> Void,
        onResendClick: @escaping () -> Void = {}
    ) {
        self.mission = mission
        self.isAdminUser = isAdminUser
        self.onEditClick = onEditClick
        self.onDeleteClick = onDeleteClick
        self.onReportClick = onReportClick
        self.onResendClick = onResendClick
    }
    
    var body: some View {
        switch mission.state {
            case .error: ErrorMissionBottomSheet(
                onDeleteClick: onDeleteClick,
                onResendClick: onResendClick
            )
            
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
    let onResendClick: () -> Void
    
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
