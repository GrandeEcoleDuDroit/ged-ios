import SwiftUI

struct NewsNavigation: View {
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @State private var path: [NewsRoute] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            NewsDestination(
                onAnnouncementClick: { announcementId in
                    path.append(.readAnnouncement(announcementId: announcementId))
                },
                onCreateAnnouncementClick: { path.append(.createAnnouncement) }
            )
            .onAppear {
                tabBarVisibility.show = true
            }
            .background(Color.background)
            .navigationDestination(for: NewsRoute.self) { route in
                switch route {
                    case let .readAnnouncement(announcementId):
                        ReadAnnouncementDestination(
                            announcementId: announcementId,
                            onEditAnnouncementClick: { announcement in
                                path.append(.editAnnouncement(announcement: announcement))
                            },
                            onBackClick: { path.removeLast() }
                        ).onAppear {
                            tabBarVisibility.show = false
                        }
                        .background(Color.background)

                    case let .editAnnouncement(announcement):
                        EditAnnouncementDestination(
                            announcement: announcement,
                            onBackClick: { path.removeLast() }
                        ).onAppear {
                            tabBarVisibility.show = false
                        }
                        
                    case .createAnnouncement:
                        CreateAnnouncementDestination(
                            onBackClick: { path.removeLast() }
                        ).onAppear {
                            tabBarVisibility.show = false
                        }
                        .background(Color.background)
                }
            }
        }
    }
}

enum NewsRoute: Route {
    case readAnnouncement(announcementId: String)
    case editAnnouncement(announcement: Announcement)
    case createAnnouncement
}
