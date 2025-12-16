import SwiftUI

struct NewsNavigation: View {
    @StateObject private var viewModel = NewsMainThreadInjector.shared.resolve(NewsNavigationViewModel.self)

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            NewsDestination(
                onAnnouncementClick: { announcementId in
                    viewModel.path.append(.readAnnouncement(announcementId: announcementId))
                },
                onCreateAnnouncementClick: { viewModel.path.append(.createAnnouncement) },
                onEditAnnouncementClick: { announcement in
                    viewModel.path.append(.editAnnouncement(announcement: announcement))
                },
                onSeeAllAnnouncementClick: { viewModel.path.append(.allAnnouncements) }
            )
            .toolbar(viewModel.path.isEmpty ? .visible : .hidden, for: .tabBar)
            .background(.appBackground)
            .navigationDestination(for: NewsRoute.self) { route in
                switch route {
                    case let .readAnnouncement(announcementId):
                        ReadAnnouncementDestination(
                            announcementId: announcementId,
                            onAuthorClick: { user in
                                viewModel.path.append(.authorProfile(user: user))
                            },
                            onEditAnnouncementClick: { announcement in
                                viewModel.path.append(.editAnnouncement(announcement: announcement))
                            },
                            onBackClick: { viewModel.path.removeLast() }
                        )
                        .background(.appBackground)

                    case let .editAnnouncement(announcement):
                        EditAnnouncementDestination(
                            announcement: announcement,
                            onBackClick: { viewModel.path.removeLast() }
                        )
                        .background(.appBackground)
                        
                    case .createAnnouncement:
                        CreateAnnouncementDestination(
                            onBackClick: { viewModel.path.removeLast() }
                        )
                        .background(.appBackground)
                        
                    case let .authorProfile(user):
                        UserDestination(user: user)
                            .background(.appBackground)
                        
                    case .allAnnouncements:
                        AllAnnouncementsDestination(
                            onAnnouncementClick: { announcementId in
                                viewModel.path.append(.readAnnouncement(announcementId: announcementId))
                            },
                            onEditAnnouncementClick: { announcement in
                                viewModel.path.append(.editAnnouncement(announcement: announcement))
                            },
                            onAuthorClick: { user in
                                viewModel.path.append(.authorProfile(user: user))
                            }
                        )
                        .background(.appBackground)
                }
            }
        }
    }
}
