import SwiftUI

struct MissionSheet: View {
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
            case .error: ErrorMissionSheet(
                onDeleteClick: onDeleteClick,
                onResendClick: onResendClick
            )
            
            default:
                if isAdminUser {
                    EditableMissionSheet(
                        onEditClick: onEditClick,
                        onDeleteClick: onDeleteClick
                    )
                } else {
                    NonEditableMissionSheet(onReportClick: onReportClick)
                }
        }
    }
}

private struct ErrorMissionSheet: View {
    let onDeleteClick: () -> Void
    let onResendClick: () -> Void
    
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

private struct EditableMissionSheet: View {
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

private struct NonEditableMissionSheet: View {
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
