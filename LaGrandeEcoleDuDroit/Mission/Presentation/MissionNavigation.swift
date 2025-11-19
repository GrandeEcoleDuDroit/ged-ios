import SwiftUI

struct MissionNavigation: View {
    private var viewModel = MissionMainThreadInjector.shared.resolve(MissionNavigationViewModel.self)
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @State var path: [MissionRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            MissionDestination(
                onMissionClick: { missionId in
                    path.append(.mission(missionId: missionId))
                }
            )
            .onAppear {
                tabBarVisibility.show = true
                viewModel.setCurrentRoute(MessageMainRoute.conversation)
            }
            .background(Color.background)
            .navigationDestination(for: MissionRoute.self) { route in
                switch route {
                    case .mission:
                        EmptyView()
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
    case mission(missionId: String)
}

enum MissionMainRoute: MainRoute {
    case mission
}
