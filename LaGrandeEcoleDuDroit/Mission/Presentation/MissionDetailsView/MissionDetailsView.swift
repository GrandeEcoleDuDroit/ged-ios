import SwiftUI

struct MissionDetailsDestination: View {
    private let onBackClick: () -> Void
    private let onEditMissionClick: (Mission) -> Void
    private let onManagerClick: (User) -> Void
    private let onParticipantClick: (User) -> Void
    
    @StateObject private var viewModel: MissionDetailsViewModel
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
    init(
        missionId: String,
        onBackClick: @escaping () -> Void,
        onEditMissionClick: @escaping (Mission) -> Void,
        onManagerClick: @escaping (User) -> Void,
        onParticipantClick: @escaping (User) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: MissionMainThreadInjector.shared.resolve(MissionDetailsViewModel.self, arguments: missionId)!
        )
        self.onBackClick = onBackClick
        self.onEditMissionClick = onEditMissionClick
        self.onManagerClick = onManagerClick
        self.onParticipantClick = onParticipantClick
    }
    
    var body: some View {
        if let currentUser = viewModel.uiState.currentUser,
           let mission = viewModel.uiState.mission
        {
            MissionDetailsView(
                user: currentUser,
                mission: mission,
                loading: viewModel.uiState.loading,
                isManager: viewModel.uiState.isManager,
                buttonState: viewModel.uiState.buttonState,
                onBackClick: onBackClick,
                onRegisterMissionClick: viewModel.registerToMission,
                onUnregisterMissionClick: viewModel.unregisterFromMission,
                onManagerClick: onManagerClick,
                onParticipantClick: onParticipantClick,
                onRemoveParticipantsClick: viewModel.removeParticipant,
                onEditMissionClick: onEditMissionClick,
                onDeleteMissionClick: viewModel.deleteMission
            )
            .onReceive(viewModel.$event) { event in
                if let event = event as? MissionDetailsViewModel.MissionDetailsUiEvent,
                   event == .missionDeleted
                {
                    onBackClick()
                } else if let errorEvent = event as? ErrorEvent {
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

private struct MissionDetailsView: View {
    let user: User
    let mission: Mission
    let loading: Bool
    let isManager: Bool
    let buttonState: MissionDetailsViewModel.MissionButtonState
    let onBackClick: () -> Void
    let onRegisterMissionClick: () -> Void
    let onUnregisterMissionClick: () -> Void
    let onManagerClick: (User) -> Void
    let onParticipantClick: (User) -> Void
    let onRemoveParticipantsClick: (String) -> Void
    let onEditMissionClick: (Mission) -> Void
    let onDeleteMissionClick: () -> Void
    
    @State private var imageTopBar: Bool = true
    @State private var scrollPosition: CGPoint = .zero
    
    @State private var showDeleteMissionAlert: Bool = false
    @State private var showUnregisterMissionAlert: Bool = false
    @State private var showRemoveParticipantAlert: Bool = false
    
    @State private var showMissionBottomSheet: Bool = false
    @State private var showParticipantBottomSheet: Bool = false
    
    @State private var clickedParticipant: User? = nil

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Dimens.mediumPadding) {
                    MissionImage(
                        missionState: mission.state,
                        defaultImageScale: 1.4
                    )
                    .frame(height: 200)
                    .clipped()
                    
                    VStack(spacing: Dimens.mediumPadding) {
                        MissionDetailsTitleAndDescriptionSection(mission: mission)
                            .padding(.horizontal)
                        
                        HorizontalDivider()
                            .padding(.horizontal)
                        
                        MissionDetailsInformationSection(mission: mission)
                            .padding(.horizontal)
                        
                        HorizontalDivider()
                            .padding(.horizontal)
                        
                        MissionDetailsManagerSection(
                            managers: mission.managers,
                            onManagerClick: onManagerClick
                        )
                        
                        HorizontalDivider()
                            .padding(.horizontal)
                        
                        MissionDetailsParticipantSection(
                            participants: mission.participants,
                            onParticipantClick: onParticipantClick,
                            onLongParticipantClick: { participant in
                                if isManager {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    clickedParticipant = participant
                                    showParticipantBottomSheet = true
                                }
                            }
                        )
                        
                        if !mission.tasks.isEmpty {
                            HorizontalDivider()
                                .padding(.horizontal)
                            
                            MissionDetailsTaskSection(missionTasks: mission.tasks)
                                .padding(.horizontal)
                        }
                    }
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geometry.frame(in: .named("scroll")).origin
                            )
                    }
                )
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    self.scrollPosition = value
                }
            }
            .coordinateSpace(name: "scroll")
            .onChange(of: scrollPosition) { newValue in
                imageTopBar = scrollPosition.y >= -200
            }
            
            MissionDetailsTopBar(
                title: mission.title,
                imageTopBar: imageTopBar,
                onBackClick: onBackClick,
                onOptionsClick: { showMissionBottomSheet = true }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            Group {
                switch buttonState {
                    case let .register(enabled):
                        RegisterButton(
                            enabled: enabled,
                            loading: loading,
                            onClick: onRegisterMissionClick
                        )
                        
                    case .registered:
                        RegisteredButton(
                            loading: loading,
                            onClick: { showUnregisterMissionAlert = true }
                        )
                        
                    case .complete: CompleteButton()
                        
                    case .hidden: EmptyView()
                }
            }
            .padding(.vertical, Dimens.smallMediumPadding)
            .padding(.horizontal, Dimens.mediumPadding)
            .background(Color.background)
        }
        .sheet(isPresented: $showMissionBottomSheet) {
            MissionBottomSheet(
                mission: mission,
                editable: isManager,
                onDeleteClick: {
                    showMissionBottomSheet = false
                    showDeleteMissionAlert = true
                }
            )
        }
        .sheet(isPresented: $showParticipantBottomSheet) {
            BottomSheetContainer(fraction: Dimens.bottomSheetFraction(itemCount: 1)) {
                Button(
                    action: {
                        showParticipantBottomSheet = false
                        showRemoveParticipantAlert = true
                    }
                ) {
                    TextItem(
                        text: Text(stringResource(.remove)),
                        image: Image(systemName: "person.badge.minus")
                    )
                }
            }
        }
        .alert(
            stringResource(.deleteMissionAlertMessage),
            isPresented: $showDeleteMissionAlert
        ) {
            Button(stringResource(.cancel), role: .cancel) {
                showDeleteMissionAlert = false
            }
            
            Button(stringResource(.delete), role: .destructive) {
                showDeleteMissionAlert = false
                onDeleteMissionClick()
            }
        }
        .alert(
            stringResource(.unregisterMissionAlertMessage),
            isPresented: $showUnregisterMissionAlert
        ) {
            Button(stringResource(.cancel), role: .cancel) {
                showUnregisterMissionAlert = false
            }
            
            Button(stringResource(.confirm)) {
                showUnregisterMissionAlert = false
                onUnregisterMissionClick()
            }
        }
        .alert(
            stringResource(.removeParticipantAlertMessage),
            isPresented: $showRemoveParticipantAlert,
            presenting: clickedParticipant
        ) { participant in
            Button(stringResource(.cancel), role: .cancel) {
                showRemoveParticipantAlert = false
            }
            
            Button(stringResource(.remove), role: .destructive) {
                showRemoveParticipantAlert = false
                onRemoveParticipantsClick(participant.id)
                clickedParticipant = nil
            }
        }
    }
}

private struct RegisterButton: View {
    let enabled: Bool
    let loading: Bool
    let onClick: () -> Void
    
    var body: some View {
        LoadingButton(
            label: stringResource(.registerMissionButtonText),
            loading: loading,
            action: onClick,
            enabled: enabled
        )
    }
}

private struct RegisteredButton: View {
    let loading: Bool
    let onClick: () -> Void
    
    var body: some View {
        LoadingButton(
            label: stringResource(.registeredMissionButtonText),
            loading: loading,
            action: onClick,
            containerColor: .activatedButtonContainer,
            contentColor: .activatedButtonContent
        )
    }
}

private struct CompleteButton: View {
    var body: some View {
        PrimaryButton(
            label: stringResource(.completeMissionButtonText),
            action: {},
            enabled: false
        )
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

#Preview {
    NavigationStack {
        MissionDetailsView(
            user: userFixture,
            mission: missionFixture,
            loading: false,
            isManager: true,
            buttonState: .register(),
            onBackClick: {},
            onRegisterMissionClick: {},
            onUnregisterMissionClick: {},
            onManagerClick: { _ in },
            onParticipantClick: { _ in },
            onRemoveParticipantsClick: { _ in },
            onEditMissionClick: { _ in },
            onDeleteMissionClick: {}
        )
        .background(Color.background)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
