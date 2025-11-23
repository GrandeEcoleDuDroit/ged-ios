import SwiftUI

struct MissionDestination: View {
    let onMissionClick: (String) -> Void
    let onCreateMissionClick: () -> Void
    
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
                onDeleteMissionClick: viewModel.deleteMission,
                onRefreshMissions: viewModel.refreshMissions
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
    let onDeleteMissionClick: (Mission) -> Void
    let onRefreshMissions: () async -> Void
    
    @State private var showMissionBottomSheet: Bool = false
    @State private var showDeleteMissionAlert: Bool = false
    @State private var clickedMission: Mission?
    
    var body: some View {
        VStack {
            if let missions {
                List {
                    if missions.isEmpty {
                        Text(stringResource(.noMission))
                            .foregroundStyle(.informationText)
                            .listRowBackground(Color.background)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .frame(maxWidth: .infinity, alignment: .top)
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
                                onOptionClick: {
                                    clickedMission = mission
                                    showMissionBottomSheet = true
                                }
                            )
                            .padding(.horizontal)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                        }
                        .listRowBackground(Color.background)
                    }
                }
                .scrollIndicators(.hidden)
                .listStyle(.plain)
                .listRowSpacing(Dimens.largePadding)
                .refreshable { await onRefreshMissions() }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            
        }
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
                onDeleteMissionClick: {
                    showMissionBottomSheet = false
                    showDeleteMissionAlert = true
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
                    if let clickedMission {
                        onDeleteMissionClick(clickedMission)
                    }
                    showDeleteMissionAlert = false
                }
            }
        )
    }
}

private struct BottomSheet: View {
    let user: User
    @Binding var mission: Mission?
    let onDeleteMissionClick: () -> Void
    
    var body: some View {
        if let mission {
            MissionBottomSheet(
                mission: mission,
                editable: mission.managers.contains(user),
                onDeleteClick: onDeleteMissionClick
            )
        } else {
            BottomSheetContainer(fraction: 0.12) {
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
            onDeleteMissionClick: { _ in },
            onRefreshMissions: {}
        )
        .background(Color.background)
        .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
    }
}
