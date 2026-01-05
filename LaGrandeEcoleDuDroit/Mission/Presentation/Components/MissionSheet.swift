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
            case .published:
                PublishedMissionSheet(
                    admin: isAdminUser,
                    onEditClick: onEditClick,
                    onDeleteClick: onDeleteClick,
                    onReportClick: onReportClick
                )
                
            case .publishing:
                PublishingMissionSheet(onDeleteClick: onDeleteClick)
                
            case .error:
                ErrorMissionSheet(
                    onDeleteClick: onDeleteClick,
                    onResendClick: onResendClick
                )
                
            default: EmptyView()
        }
    }
}

private struct PublishedMissionSheet: View {
    let admin: Bool
    let onEditClick: () -> Void
    let onDeleteClick: () -> Void
    let onReportClick: () -> Void
    
    var body: some View {
        if admin {
            SheetContainer(fraction: Dimens.sheetFraction(itemCount: 2)) {
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
            SheetContainer(fraction: Dimens.sheetFraction(itemCount: 1)) {
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

private struct PublishingMissionSheet: View {
    let onDeleteClick: () -> Void
    
    var body: some View {
        SheetContainer(fraction: Dimens.sheetFraction(itemCount: 1)) {
            SheetItem(
                icon: Image(systemName: "trash"),
                text: stringResource(.delete),
                onClick: onDeleteClick
            )
            .foregroundColor(.red)
        }
    }
}

private struct ErrorMissionSheet: View {
    let onDeleteClick: () -> Void
    let onResendClick: () -> Void
    
    var body: some View {
        SheetContainer(fraction: Dimens.sheetFraction(itemCount: 2)) {
            SheetItem(
                icon: Image(systemName: "arrow.clockwise"),
                text: stringResource(.retry),
                onClick: onResendClick
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
