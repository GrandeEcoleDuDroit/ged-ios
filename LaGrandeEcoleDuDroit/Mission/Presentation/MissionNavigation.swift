import SwiftUI

struct MissionNavigation: View {
    @StateObject private var viewModel = MissionMainThreadInjector.shared.resolve(MissionNavigationViewModel.self)

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            MissionDestination(
                onMissionClick: { viewModel.path.append(.missionDetails(missionId: $0)) },
                onCreateMissionClick: { viewModel.path.append(.createMission) },
                onEditMissionClick: { viewModel.path.append(.editMission(mission: $0)) }
            )
            .toolbar(viewModel.path.isEmpty ? .visible : .hidden, for: .tabBar)
            .background(.appBackground)
            .navigationDestination(for: MissionRoute.self) { route in
                switch route {
                    case .createMission:
                        CreateMissionDestination(onBackClick: { viewModel.path.removeLast() })
                            .background(.appBackground)
                        
                    case let .editMission(mission):
                        EditMissionDestination(
                            onBackClick: { viewModel.path.removeLast() },
                            mission: mission
                        )
                        .background(.appBackground)
                        
                    case let .missionDetails(missionId):
                        MissionDetailsDestination(
                            missionId: missionId,
                            onBackClick: { viewModel.path.removeLast() },
                            onEditMissionClick: { viewModel.path.append(.editMission(mission: $0)) },
                            onManagerClick: { viewModel.path.append(.userProfile(user: $0)) },
                            onParticipantClick: { viewModel.path.append(.userProfile(user: $0)) }
                        )
                        .background(.appBackground)
                        
                    case let .userProfile(user):
                        UserDestination(user: user)
                            .background(.appBackground)
                }
            }
        }
    }
}
