import SwiftUI

struct MissionNavigation: View {
    private var viewModel = MissionMainThreadInjector.shared.resolve(MissionNavigationViewModel.self)
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @State private var path: [MissionRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            MissionDestination(
                onMissionClick: { path.append(.missionDetails(missionId: $0)) },
                onCreateMissionClick: { path.append(.createMission) },
                onEditMissionClick: { path.append(.editMission(mission: $0)) }
            )
            .onAppear {
                tabBarVisibility.show = true
                viewModel.setCurrentRoute(MissionMainRoute.mission)
            }
            .background(.appBackground)
            .navigationDestination(for: MissionRoute.self) { route in
                switch route {
                    case .createMission:
                        CreateMissionDestination(onBackClick: { path.removeLast() })
                            .onAppear {
                                tabBarVisibility.show = false
                                viewModel.setCurrentRoute(route)
                            }
                            .background(.appBackground)
                        
                    case let .editMission(mission):
                        EditMissionDestination(
                            onBackClick: { path.removeLast() },
                            mission: mission
                        )
                        .onAppear {
                            tabBarVisibility.show = false
                            viewModel.setCurrentRoute(route)
                        }
                        .background(.appBackground)
                        
                    case let .missionDetails(missionId):
                        MissionDetailsDestination(
                            missionId: missionId,
                            onBackClick: { path.removeLast() },
                            onEditMissionClick: { path.append(.editMission(mission: $0)) },
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
                        .background(.appBackground)
                        
                    case let .userProfile(user):
                        UserDestination(user: user)
                        .onAppear {
                            tabBarVisibility.show = false
                            viewModel.setCurrentRoute(route)
                        }
                        .background(.appBackground)
                }
            }
        }
    }
}

enum MissionRoute: Route {
    case createMission
    case editMission(mission: Mission)
    case missionDetails(missionId: String)
    case userProfile(user: User)
}

enum MissionMainRoute: MainRoute {
    case mission
}
