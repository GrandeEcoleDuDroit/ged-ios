import SwiftUI

struct MissionNavigation: View {
    private var viewModel = MissionMainThreadInjector.shared.resolve(MissionNavigationViewModel.self)
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @State private var path: [MissionRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            MissionDestination(
                onMissionClick: { path.append(.missionDetails(missionId: $0)) },
                onCreateMissionClick: { path.append(.createMission) }
            )
            .onAppear {
                tabBarVisibility.show = true
                viewModel.setCurrentRoute(MissionMainRoute.mission)
            }
            .background(Color.background)
            .navigationDestination(for: MissionRoute.self) { route in
                switch route {
                    case .createMission:
                        CreateMissionDestination(onBackClick: { path.removeLast() })
                            .onAppear {
                                tabBarVisibility.show = false
                                viewModel.setCurrentRoute(route)
                            }
                            .background(Color.background)
                        
                    case let .missionDetails(missionId):
                        MissionDetailsDestination(
                            missionId: missionId,
                            onBackClick: { path.removeLast() },
                            onEditMissionClick: { _ in },
                            onManagerClick: { path.append(.userProfile(user: $0)) },
                            onParticipantClick: { path.append(.userProfile(user: $0)) }
                        ).onAppear {
                            tabBarVisibility.show = false
                            viewModel.setCurrentRoute(route)
                            EnableSwipeBack.enabled = true
                        }
                        .onDisappear {
                            EnableSwipeBack.enabled = false
                        }
                        .background(Color.background)
                        
                    case let .userProfile(user):
                        UserDestination(user: user)
                        .onAppear {
                            tabBarVisibility.show = false
                            viewModel.setCurrentRoute(route)
                        }
                        .background(Color.background)
                }
            }
        }
    }
}

enum MissionRoute: Route {
    case createMission
    case missionDetails(missionId: String)
    case userProfile(user: User)
}

enum MissionMainRoute: MainRoute {
    case mission
}
