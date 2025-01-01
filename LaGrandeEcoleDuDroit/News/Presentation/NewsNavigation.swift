import SwiftUI

struct NewsNavigation: View {
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @StateObject private var newsNavigationCoordinator = NavigationCoordinator()
    @StateObject private var newsViewModel = DependencyContainer.shared.newsViewModel
    
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
    struct NewsNavigation_Previews: View {
        @StateObject private var navigationCoordinator = NavigationCoordinator()
        
        var body: some View {
            NavigationStack(path: $navigationCoordinator.path) {
                NewsView()
                    .environmentObject(DependencyContainer.shared.mockNewsViewModel)
                    .environmentObject(TabBarVisibility())
                    .environmentObject(navigationCoordinator)
                    .navigationDestination(for: NewsScreen.self) { screen in
                        switch screen {
                        case .announcementDetail(let announcement):
                            AnnouncementDetailView(announcement: announcement)
                                .environmentObject(DependencyContainer.shared.mockNewsViewModel)
                        case .createAnnouncement:
                            CreateAnnouncementView()
                                .environmentObject(DependencyContainer.shared.mockNewsViewModel)
                        }
                    }
            }
            .environmentObject(navigationCoordinator)
        }
    }
    
    return NewsNavigation_Previews()
}
