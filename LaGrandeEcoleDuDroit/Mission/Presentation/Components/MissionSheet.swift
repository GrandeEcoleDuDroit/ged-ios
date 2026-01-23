import SwiftUI

struct MissionSheet: View {
    let mission: Mission
    let user: User
    let onEditClick: () -> Void
    let onDeleteClick: () -> Void
    let onReportClick: () -> Void
    let onResendClick: () -> Void
    
    init(
        mission: Mission,
        user: User,
        onEditClick: @escaping () -> Void,
        onDeleteClick: @escaping () -> Void,
        onReportClick: @escaping () -> Void,
        onResendClick: @escaping () -> Void = {}
    ) {
        self.mission = mission
        self.user = user
        self.onEditClick = onEditClick
        self.onDeleteClick = onDeleteClick
        self.onReportClick = onReportClick
        self.onResendClick = onResendClick
    }
    
    var body: some View {
        switch mission.state {
            case .published:
                PublishedMissionSheet(
                    isAdmin: user.admin,
                    isManager: mission.managers.contains { $0.id ==  user.id },
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
    let isAdmin: Bool
    let isManager: Bool
    let onEditClick: () -> Void
    let onDeleteClick: () -> Void
    let onReportClick: () -> Void
    
    var itemCount: Int {
        isAdmin ? 2 : 1
    }
    
    var body: some View {
        if isAdmin || isManager {
            SheetContainer(fraction: DimensResource.sheetFraction(itemCount: itemCount)) {
                SheetItem(
                    icon: Image(systemName: "pencil"),
                    text: stringResource(.edit),
                    onClick: onEditClick
                )
                
                if isAdmin {
                    SheetItem(
                        icon: Image(systemName: "trash"),
                        text: stringResource(.delete),
                        onClick: onDeleteClick
                    )
                    .foregroundColor(.red)
                }
            }
        } else {
            SheetContainer(fraction: DimensResource.sheetFraction(itemCount: 1)) {
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
        SheetContainer(fraction: DimensResource.sheetFraction(itemCount: 1)) {
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
        SheetContainer(fraction: DimensResource.sheetFraction(itemCount: 2)) {
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
