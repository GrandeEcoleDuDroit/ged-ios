import SwiftUI

struct NewsNavigation: View {
    private let viewModel = NewsMainThreadInjector.shared.resolve(NewsNavigationViewModel.self)
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @State var path: [NewsRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            NewsDestination(
                onAnnouncementClick: { announcementId in
                    path.append(.readAnnouncement(announcementId: announcementId))
                },
                onCreateAnnouncementClick: { path.append(.createAnnouncement) },
                onEditAnnouncementClick: { announcement in
                    path.append(.editAnnouncement(announcement: announcement))
                },
                onSeeAllAnnouncementClick: { path.append(.seeAllAnnouncements) }
            )
            .onAppear {
                tabBarVisibility.show = true
                viewModel.setCurrentRoute(NewsMainRoute.news)
            }
            .background(Color.background)
            .navigationDestination(for: NewsRoute.self) { route in
                switch route {
                    case let .readAnnouncement(announcementId):
                        ReadAnnouncementDestination(
                            announcementId: announcementId,
                            onAuthorClick: { user in
                                path.append(.seeAuthor(user: user))
                            },
                            onEditAnnouncementClick: { announcement in
                                path.append(.editAnnouncement(announcement: announcement))
                            },
                            onBackClick: { path.removeLast() }
                        )
                        .onAppear {
                            tabBarVisibility.show = false
                            viewModel.setCurrentRoute(route)
                        }
                        .background(Color.background)

                    case let .editAnnouncement(announcement):
                        EditAnnouncementDestination(
                            announcement: announcement,
                            onBackClick: { path.removeLast() }
                        )
                        .onAppear {
                            tabBarVisibility.show = false
                            viewModel.setCurrentRoute(route)
                        }
                        .background(Color.background)
                        
                    case .createAnnouncement:
                        CreateAnnouncementDestination(
                            onBackClick: { path.removeLast() }
                        )
                        .onAppear {
                            tabBarVisibility.show = false
                            viewModel.setCurrentRoute(route)
                        }
                        .background(Color.background)
                        
                    case let .seeAuthor(user):
                        UserDestination(user: user)
                        .onAppear {
                            tabBarVisibility.show = false
                            viewModel.setCurrentRoute(route)
                        }
                        .background(Color.background)
                        
                    case .seeAllAnnouncements:
                        AllAnnouncementsDestination(
                            onAnnouncementClick: { announcementId in
                                path.append(.readAnnouncement(announcementId: announcementId))
                            },
                            onEditAnnouncementClick: { announcement in
                                path.append(.editAnnouncement(announcement: announcement))
                            },
                            onAuthorClick: { user in
                                path.append(.seeAuthor(user: user))
                            }
                        )
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

enum NewsRoute: Route {
    case readAnnouncement(announcementId: String)
    case editAnnouncement(announcement: Announcement)
    case createAnnouncement
    case seeAuthor(user: User)
    case seeAllAnnouncements
}

enum NewsMainRoute: MainRoute {
    case news
}
