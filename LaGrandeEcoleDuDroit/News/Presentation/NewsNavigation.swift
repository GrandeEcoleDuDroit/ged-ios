import SwiftUI

struct NewsNavigation: View {
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @StateObject private var newsNavigationCoordinator = CommonDependencyInjectionContainer.shared.resolve(NavigationCoordinator.self)
    @StateObject private var newsViewModel = NewsDependencyInjectionContainer.shared.resolve(NewsViewModel.self)
    
    var body: some View {
        NavigationStack(path: $newsNavigationCoordinator.path) {
            NewsView()
                .environmentObject(newsViewModel)
                .navigationDestination(for: NewsScreen.self) { screen in
                    switch screen {
                    case .announcementDetail(let announcement):
                        AnnouncementDetailView(announcement: announcement)
                            .environmentObject(newsViewModel)
                    case .createAnnouncement:
                        CreateAnnouncementView()
                            .environmentObject(newsViewModel)
                    }
                }
        }
        .environmentObject(newsNavigationCoordinator)
        .environmentObject(tabBarVisibility)
    }
}

#Preview {
    struct NewsNavigation_Preview: View {
        @StateObject var navigationCoordinator = CommonDependencyInjectionContainer.shared.resolve(NavigationCoordinator.self)
        let tabBarVisibility = CommonDependencyInjectionContainer.shared.resolve(TabBarVisibility.self)
        let mockNewsViewModel = NewsDependencyInjectionContainer.shared.resolveWithMock().resolve(NewsViewModel.self)!
        
        var body: some View {
            NavigationStack(path: $navigationCoordinator.path) {
                NewsView()
                    .navigationDestination(for: NewsScreen.self) { screen in
                        switch screen {
                        case .announcementDetail(let announcement):
                            AnnouncementDetailView(announcement: announcement)
                        case .createAnnouncement:
                            CreateAnnouncementView()
                        }
                    }
            }
            .environmentObject(navigationCoordinator)
            .environmentObject(mockNewsViewModel)
            .environmentObject(tabBarVisibility)
        }
    }
    
    return NewsNavigation_Preview()
}
