import SwiftUI

struct NewsNavigation: View {
    @StateObject private var newsNavigationCoordinator = NavigationCoordinator()
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    
    var body: some View {
        NavigationStack(path: $newsNavigationCoordinator.path) {
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
        .environmentObject(newsNavigationCoordinator)
        .environmentObject(tabBarVisibility)
    }
}

#Preview {
    struct NewsNavigation_Preview: View {
        @StateObject var navigationCoordinator = NavigationCoordinator()
        @StateObject var tabBarVisibility = TabBarVisibility()
        
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
            .environmentObject(tabBarVisibility)
        }
    }
    
    return NewsNavigation_Preview()
}
