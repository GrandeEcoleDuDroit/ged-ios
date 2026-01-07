import SwiftUI

struct MissionDetailsDestination: View {
    private let onBackClick: () -> Void
    private let onManagerClick: (User) -> Void
    private let onParticipantClick: (User) -> Void
    
    @StateObject private var viewModel: MissionDetailsViewModel
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
    init(
        missionId: String,
        onBackClick: @escaping () -> Void,
        onManagerClick: @escaping (User) -> Void,
        onParticipantClick: @escaping (User) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: MissionMainThreadInjector.shared.resolve(MissionDetailsViewModel.self, arguments: missionId)!
        )
        self.onBackClick = onBackClick
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
                onDeleteMissionClick: viewModel.deleteMission,
                onReportMissionClick: viewModel.reportMission
            )
            .onReceive(viewModel.$event) { event in
                if case let event as MissionDetailsViewModel.MissionDetailsUiEvent = event {
                    switch event {
                        case .missionDeleted: onBackClick()
                    }
                } else if case let event as ErrorEvent = event {
                    errorMessage = event.message
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

private struct MissionDetailsView: View {
    let user: User
    let mission: Mission
    let loading: Bool
    let isManager: Bool
    let buttonState: MissionDetailsViewModel.MissionButtonState?
    let onBackClick: () -> Void
    let onRegisterMissionClick: () -> Void
    let onUnregisterMissionClick: () -> Void
    let onManagerClick: (User) -> Void
    let onParticipantClick: (User) -> Void
    let onRemoveParticipantsClick: (String) -> Void
    let onDeleteMissionClick: () -> Void
    let onReportMissionClick: (MissionReport) -> Void
    
    @State private var defaultTopBar: Bool = false
    @State private var scrollPosition: CGPoint = .zero
    @State private var showDeleteMissionAlert: Bool = false
    @State private var showUnregisterMissionAlert: Bool = false
    @State private var showRemoveParticipantAlert: Bool = false
    @State private var alertParticipant: User?
    @State private var activeSheet: MissionDetailsViewSheet?

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Dimens.mediumPadding) {
                    MissionImage(
                        missionState: mission.state,
                        defaultImageScale: 1.4
                    )
                    .ignoresSafeArea(.all)
                    .frame(height: MissionUtilsPresentation.missionImageHeight)
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
                            onParticipantClick: {
                                if user.id != $0.id && (isManager || user.admin) {
                                    activeSheet = .participant($0)
                                } else {
                                    onParticipantClick($0)
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
                defaultTopBar = scrollPosition.y <= -200
            }
            
            if !defaultTopBar {
                MissionImageTopBar(
                    onBackClick: onBackClick,
                    onOptionsClick: { activeSheet = .mission }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .navigationBarBackButtonHidden(!defaultTopBar)
        .navigationTitle(defaultTopBar ? mission.title : "")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                OptionsButton(action: { activeSheet = .mission })
            }
        }
        .toolbar(defaultTopBar ? .visible : .hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            if let buttonState {
                BottomSection(
                    buttonState: buttonState,
                    loading: loading,
                    onRegisterMissionClick: onRegisterMissionClick,
                    onUnregisterMissionClick: { showUnregisterMissionAlert = true }
                )
                .padding(.bottom, Dimens.smallMediumPadding)
                .padding(.top, Dimens.mediumPadding)
                .padding(.horizontal, Dimens.mediumPadding)
                .background(.appBackground)
            }
        }
        .sheet(item: $activeSheet) {
            switch $0 {
                case .mission:
                    MissionSheet(
                        mission: mission,
                        isAdminUser: user.admin,
                        onEditClick: {
                            activeSheet = .editMission
                        },
                        onDeleteClick: {
                            activeSheet = nil
                            showDeleteMissionAlert = true
                        },
                        onReportClick: {
                            activeSheet = .missionReport
                        }
                    )
                    
                case let .participant(user):
                    SheetContainer(fraction: Dimens.sheetFraction(itemCount: 2)) {
                        SheetItem(
                            icon: Image(systemName: "person"),
                            text: stringResource(.seeProfile),
                            onClick: {
                                activeSheet = nil
                                onParticipantClick(user)
                            }
                        )
                        
                        SheetItem(
                            icon: Image(systemName: "person.badge.minus"),
                            text: stringResource(.remove),
                            onClick: {
                                activeSheet = nil
                                alertParticipant = user
                                showRemoveParticipantAlert = true
                            }
                        )
                        .foregroundStyle(.error)
                    }
                    
                case .missionReport:
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
                    
                case .editMission:
                    EditMissionDestination(
                        onBackClick: { activeSheet = nil },
                        mission: mission
                    )
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
            stringResource(.removeParticipantAlertMessage, alertParticipant?.fullName ?? ""),
            isPresented: $showRemoveParticipantAlert,
            presenting: alertParticipant
        ) { participant in
            Button(stringResource(.cancel), role: .cancel) {
                showRemoveParticipantAlert = false
            }
            
            Button(stringResource(.remove), role: .destructive) {
                alertParticipant = nil
                showRemoveParticipantAlert = false
                onRemoveParticipantsClick(participant.id)
            }
        }
    }
}

private struct BottomSection: View {
    let buttonState: MissionDetailsViewModel.MissionButtonState
    let loading: Bool
    let onRegisterMissionClick: () -> Void
    let onUnregisterMissionClick: () -> Void
    
    var body: some View {
        switch buttonState {
            case .register:
                LoadingButton(
                    label: stringResource(.registerMissionButtonText),
                    loading: loading,
                    action: onRegisterMissionClick
                )
                
            case .registered:
                LoadingButton(
                    label: stringResource(.registeredMissionButtonText),
                    loading: loading,
                    action: onUnregisterMissionClick,
                    containerColor: .activatedButtonContainer,
                    contentColor: .activatedButtonContent
                )
                
            case .completed:
                PrimaryButton(
                    label: stringResource(.completedMissionButtonText),
                    action: {},
                    enabled: false
                )
                
            case let .registrationClosed(reason: reason):
                VStack {
                    Text(reason)
                        .foregroundStyle(.informationText)
                        .font(.footnote)
                    
                    PrimaryButton(
                        label: stringResource(.registrationClosedMissionButtonText),
                        action: {},
                        enabled: false
                    )
                }
                
            case let .unavailable(reason: reason):
                VStack {
                    Text(.init(reason))
                        .foregroundStyle(.informationText)
                        .font(.footnote)
                    
                    PrimaryButton(
                        label: stringResource(.unavailableMissionButtonText),
                        action: {},
                        enabled: false
                    )
                }
        }
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

private enum MissionDetailsViewSheet: Identifiable {
    case mission
    case participant(User)
    case missionReport
    case editMission
    
    var id: Int {
        switch self {
            case .mission: 0
            case .participant: 1
            case .missionReport: 2
            case .editMission: 3
        }
    }
}

#Preview {
    NavigationStack {
        MissionDetailsView(
            user: userFixture,
            mission: missionFixture,
            loading: false,
            isManager: true,
            buttonState: .registered,
            onBackClick: {},
            onRegisterMissionClick: {},
            onUnregisterMissionClick: {},
            onManagerClick: { _ in },
            onParticipantClick: { _ in },
            onRemoveParticipantsClick: { _ in },
            onDeleteMissionClick: {},
            onReportMissionClick: { _ in }
        )
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
