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
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
    let onDeleteMissionClick: () -> Void
    
    var body: some View {
        if let mission {
            MissionBottomSheet(
                mission: mission,
                editable: mission.managers.contains(user),
                onDeleteClick: onDeleteMissionClick
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
            onDeleteMissionClick: { _ in },
            onRefreshMissions: {}
        )
        .background(Color.background)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
