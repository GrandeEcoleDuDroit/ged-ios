import SwiftUI

struct MissionNavigation: View {
    @StateObject private var viewModel = MissionMainThreadInjector.shared.resolve(MissionNavigationViewModel.self)

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            MissionDestination(
                onMissionClick: { viewModel.path.append(.missionDetails(missionId: $0)) }
            )
            .toolbar(viewModel.path.isEmpty ? .visible : .hidden, for: .tabBar)
            .navigationDestination(for: MissionRoute.self) { route in
                switch route {
                    case let .missionDetails(missionId):
                        MissionDetailsDestination(
                            missionId: missionId,
                            onBackClick: { viewModel.path.removeLast() },
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
