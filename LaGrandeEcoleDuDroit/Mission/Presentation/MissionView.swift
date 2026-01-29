import SwiftUI

struct MissionDestination: View {
    let onMissionClick: (String) -> Void
    
    @StateObject private var viewModel = MissionMainThreadInjector.shared.resolve(MissionViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    
    var body: some View {
        if let user = viewModel.uiState.user {
            MissionView(
                user: user,
                missions: viewModel.uiState.missions,
                loading: viewModel.uiState.loading,
                activeFilter: viewModel.uiState.activeFilter,
                filters: viewModel.uiState.filters,
                onMissionClick: onMissionClick,
                onDeleteMissionClick: viewModel.deleteMission,
                onReportMissionClick: viewModel.reportMission,
                onRecreateMissionClick: viewModel.recreateMission,
                onRefreshMissions: viewModel.refreshMissions,
                onMissionFilterChange: viewModel.onMissionFilterChange
            )
            .onReceive(viewModel.$event) { event in
                if let errorEvent = event as? ErrorEvent {
                    errorMessage = errorEvent.message
                    showErrorAlert = true
                }
            }
            .alert(
                errorMessage,
                isPresented: $showErrorAlert,
                actions: {
                    Button(stringResource(.ok)) {
                        showErrorAlert = false
                    }
                }
            )
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(.appBackground)
        }
    }
}

private struct MissionView: View {
    let user: User
    let missions: [Mission]
    let loading: Bool
    let activeFilter: MissionViewModel.MissionFilter
    let filters: [MissionViewModel.MissionFilter]
    let onMissionClick: (String) -> Void
    let onDeleteMissionClick: (Mission) -> Void
    let onReportMissionClick: (MissionReport) -> Void
    let onRecreateMissionClick: (Mission) -> Void
    let onRefreshMissions: () async -> Void
    let onMissionFilterChange: (MissionViewModel.MissionFilter) -> Void
    
    @State private var activeSheet: MissionViewSheet?
    @State private var showDeleteMissionAlert: Bool = false
    @State private var alertMission: Mission?
    
    var body: some View {
        MissionList(
            missions: missions,
            activeFilter: activeFilter,
            filters: filters,
            onMissionClick: onMissionClick,
            onRefreshMissions: onRefreshMissions,
            onMissionFilterChange: onMissionFilterChange,
            activeSheet: $activeSheet
        )
        .loading(loading)
        .navigationTitle(stringResource(.mission))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if user.admin {
                    Button(
                        action: { activeSheet = .createMission },
                        label: { Image(systemName: "plus") }
                    )
                }
            }
        }
        .sheet(item: $activeSheet) {
            switch $0 {
                case let .mission(mission):
                    MissionSheet(
                        mission: mission,
                        user: user,
                        onEditClick: {
                            activeSheet = .editMission(mission)
                        },
                        onDeleteClick: {
                            activeSheet = nil
                            alertMission = mission
                            showDeleteMissionAlert = true
                        },
                        onReportClick: {
                            activeSheet = .missionReport(mission)
                        },
                        onResendClick: {
                            activeSheet = nil
                            onRecreateMissionClick(mission)
                        }
                    )
                    
                case let .missionReport(mission):
                    ReportSheet(
                        items: MissionReport.Reason.allCases,
                        onReportClick: { reason in
                        activeSheet = nil
                        onReportMissionClick(
                            MissionReport(
                                missionId: mission.id,
                                reporter: MissionReport.Reporter(
                                    fullName: user.fullName,
                                    email: user.email
                                ),
                                reason: reason
                            )
                        )
                    }
                )
                    
                case .createMission:
                    CreateMissionDestination(onBackClick: { activeSheet = nil })
                    
                case let .editMission(mission):
                    EditMissionDestination(
                        onBackClick: { activeSheet = nil },
                        mission: mission
                    )
            }
        }
        .alert(
            stringResource(.deleteMissionAlertMessage),
            isPresented: $showDeleteMissionAlert,
            presenting: alertMission,
            actions: { mission in
                Button(stringResource(.cancel), role: .cancel) {
                    alertMission = nil
                    showDeleteMissionAlert = false
                }
                
                Button(stringResource(.delete), role: .destructive) {
                    showDeleteMissionAlert = false
                    alertMission = nil
                    onDeleteMissionClick(mission)
                }
            }
        )
    }
}

private struct MissionList: View {
    let missions: [Mission]
    let activeFilter: MissionViewModel.MissionFilter
    let filters: [MissionViewModel.MissionFilter]
    let onMissionClick: (String) -> Void
    let onRefreshMissions: () async -> Void
    let onMissionFilterChange: (MissionViewModel.MissionFilter) -> Void
    @Binding var activeSheet: MissionViewSheet?
    
    var body: some View {
        PlainTableView(
            modifier: PlainTableModifier(
                backgroundColor: .appBackground,
                selectionStyle: .none,
                onRefresh: onRefreshMissions
            ),
            values: missions,
            onRowClick: { mission in
                if case .published = mission.state {
                    onMissionClick(mission.id)
                } else {
                    activeSheet = .mission(mission)
                }
            },
            header: {
                LazyHStack {
                    ForEach(filters, id: \.self) { filter in
                        FilterChip(
                            label: filter.label,
                            selected: filter == activeFilter,
                            onClick: { onMissionFilterChange(filter) }
                        )
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            },
            emptyContent: {
                Text(stringResource(.noMission))
                    .foregroundStyle(.informationText)
            },
            content: { mission in
                MissionCard(
                    mission: mission,
                    onOptionsClick: { activeSheet = .mission(mission) }
                )
                .padding(.horizontal)
                .padding(.vertical, DimensResource.smallMediumPadding)
            }
        )
    }
}

private enum MissionViewSheet: Identifiable {
    case mission(Mission)
    case missionReport(Mission)
    case createMission
    case editMission(Mission)
    
    var id: Int {
        switch self {
            case .mission: 0
            case .missionReport: 1
            case .createMission: 2
            case .editMission: 3
        }
    }
}

#Preview {
    NavigationStack {
        MissionView(
            user: userFixture3,
            missions: missionsFixture,
            loading: false,
            activeFilter: .open,
            filters: MissionViewModel.MissionFilter.allCases,
            onMissionClick: { _ in },
            onDeleteMissionClick: { _ in },
            onReportMissionClick: { _ in },
            onRecreateMissionClick: { _ in},
            onRefreshMissions: {},
            onMissionFilterChange: { _ in}
        )
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
