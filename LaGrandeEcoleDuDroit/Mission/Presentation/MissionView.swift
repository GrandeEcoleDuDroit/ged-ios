import SwiftUI

struct MissionDestination: View {
    let onMissionClick: (String) -> Void
    let onCreateMissionClick: () -> Void
    let onEditMissionClick: (Mission) -> Void
    
    @StateObject private var viewModel = MissionMainThreadInjector.shared.resolve(MissionViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    
    var body: some View {
        if let user = viewModel.uiState.user {
            MissionView(
                user: user,
                missions: viewModel.uiState.missions,
                loading: viewModel.uiState.loading,
                onMissionClick: onMissionClick,
                onCreateMissionClick: onCreateMissionClick,
                onEditMissionClick: onEditMissionClick,
                onDeleteMissionClick: viewModel.deleteMission,
                onReportMissionClick: viewModel.reportMission,
                onResendMissionClick: viewModel.resendMission,
                onRefreshMissions: viewModel.refreshMissions,
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
        }
    }
}

private struct MissionView: View {
    let user: User
    let missions: [Mission]?
    let loading: Bool
    let onMissionClick: (String) -> Void
    let onCreateMissionClick: () -> Void
    let onEditMissionClick: (Mission) -> Void
    let onDeleteMissionClick: (Mission) -> Void
    let onReportMissionClick: (MissionReport) -> Void
    let onResendMissionClick: (Mission) -> Void
    let onRefreshMissions: () async -> Void
    
    @State private var activeSheet: MissionViewSheet?
    @State private var showDeleteMissionAlert: Bool = false
    @State private var alertMission: Mission?
    @State private var selectedMission: Mission?
    
    var body: some View {
        List {
            if let missions {
                if missions.isEmpty {
                    Text(stringResource(.noMission))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .foregroundStyle(.informationText)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(missions) { mission in
                        MissionCard(
                            mission: mission,
                            onOptionsClick: {
                                activeSheet = .mission(mission)
                            }
                        )
                        .background(selectedMission == mission ? Color.click : Color.clear)
                        .clipShape(ShapeDefaults.medium)
                        .contentShape(.rect)
                        .listRowTap(
                            action: {
                                if case .published = mission.state {
                                    onMissionClick(mission.id)
                                } else {
                                    activeSheet = .mission(mission)
                                }
                            },
                            selectedItem: $selectedMission,
                            value: mission
                        )
                        .padding(.horizontal)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .listRowSpacing(Dimens.largePadding)
        .refreshable { await onRefreshMissions() }
        .loading(loading)
        .navigationTitle(stringResource(.mission))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if user.admin {
                    Button(
                        action: onCreateMissionClick,
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
                        isAdminUser: user.admin,
                        onEditClick: {
                            activeSheet = nil
                            onEditMissionClick(mission)
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
                            onResendMissionClick(mission)
                        }
                    )
                    
                case let .missionReport(mission):
                    ReportSheet(
                        items: MissionReport.Reason.allCases,
                        fraction: Dimens.reportSheetFraction(itemCount: MissionReport.Reason.allCases.count),
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

private enum MissionViewSheet: Identifiable {
    case mission(Mission)
    case missionReport(Mission)
    
    var id: Int {
        switch self {
            case .mission: 0
            case .missionReport: 1
        }
    }
}

#Preview {
    NavigationStack {
        MissionView(
            user: userFixture,
            missions: missionsFixture,
            loading: false,
            onMissionClick: { _ in },
            onCreateMissionClick: {},
            onEditMissionClick: { _ in },
            onDeleteMissionClick: { _ in },
            onReportMissionClick: { _ in },
            onResendMissionClick: { _ in},
            onRefreshMissions: {}
        )
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
