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
    let onRefreshMissions: () async -> Void
    
    @State private var showMissionBottomSheet: Bool = false
    @State private var showDeleteMissionAlert: Bool = false
    @State private var showReportMissionBottomSheet: Bool = false
    @State private var clickedMission: Mission?
    
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
                            onClick: {
                                if case .published = mission.state {
                                    onMissionClick(mission.id)
                                } else {
                                    clickedMission = mission
                                    showMissionBottomSheet = true
                                }
                            },
                            onOptionsClick: {
                                clickedMission = mission
                                showMissionBottomSheet = true
                            }
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
        .scrollIndicators(.hidden)
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
        .sheet(isPresented: $showMissionBottomSheet) {
            BottomSheet(
                user: user,
                mission: $clickedMission,
                onEditMissionClick: {
                    showMissionBottomSheet = false
                    if let clickedMission {
                        onEditMissionClick(clickedMission)
                    }
                },
                onDeleteMissionClick: {
                    showMissionBottomSheet = false
                    showDeleteMissionAlert = true
                },
                onReportMissionClick: {
                    showMissionBottomSheet = false
                    showReportMissionBottomSheet = true
                }
            )
        }
        .sheet(isPresented: $showReportMissionBottomSheet) {
            ReportBottomSheet(
                items: MissionReport.Reason.allCases,
                fraction: Dimens.reportBottomSheetFraction(itemCount: MissionReport.Reason.allCases.count),
                onReportClick: { reason in
                    showReportMissionBottomSheet = false
                    
                    if let clickedMission {
                        onReportMissionClick(
                            MissionReport(
                                missionId: clickedMission.id,
                                reporter: MissionReport.Reporter(
                                    fullName: user.fullName,
                                    email: user.email
                                ),
                                reason: reason
                            )
                        )
                    }
                }
            )
        }
        .alert(
            stringResource(.deleteMissionAlertMessage),
            isPresented: $showDeleteMissionAlert,
            actions: {
                Button(stringResource(.cancel), role: .cancel) {
                    showDeleteMissionAlert = false
                }
                
                Button(stringResource(.delete), role: .destructive) {
                    showDeleteMissionAlert = false
                    if let clickedMission {
                        onDeleteMissionClick(clickedMission)
                    }
                }
            }
        )
    }
}

private struct BottomSheet: View {
    let user: User
    @Binding var mission: Mission?
    let onEditMissionClick: () -> Void
    let onDeleteMissionClick: () -> Void
    let onReportMissionClick: () -> Void

    var body: some View {
        if let mission {
            MissionBottomSheet(
                mission: mission,
                isAdminUser: user.admin,
                onEditClick: onEditMissionClick,
                onDeleteClick: onDeleteMissionClick,
                onReportClick: onReportMissionClick
            )
        } else {
            BottomSheetContainer(fraction: Dimens.bottomSheetFraction(itemCount: 1)) {
                Text(stringResource(.unknownError))
                    .foregroundColor(.error)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MissionView(
            user: userFixture,
            missions: [],
            loading: false,
            onMissionClick: { _ in },
            onCreateMissionClick: {},
            onEditMissionClick: { _ in },
            onDeleteMissionClick: { _ in },
            onReportMissionClick: { _ in },
            onRefreshMissions: {}
        )
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
