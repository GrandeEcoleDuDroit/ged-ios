import SwiftUI

struct MissionNavigation: View {
    private var viewModel = MissionMainThreadInjector.shared.resolve(MissionNavigationViewModel.self)
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @State private var path: [MissionRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            MissionDestination(
                onMissionClick: { _ in },
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
                }
            }
        }
    }
}

enum MissionRoute: Route {
    case createMission
}

enum MissionMainRoute: MainRoute {
    case mission
}
