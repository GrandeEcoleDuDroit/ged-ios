import SwiftUI

struct NewsNavigation: View {
    @StateObject private var viewModel = NewsMainThreadInjector.shared.resolve(NewsNavigationViewModel.self)

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            NewsDestination(
                onAnnouncementClick: { announcementId in
                    viewModel.path.append(.readAnnouncement(announcementId: announcementId))
                },
                onSeeAllAnnouncementsClick: { viewModel.path.append(.allAnnouncements) },
                onPostClick: { postId in
                    viewModel.path.append(.readPost(postId: postId))
                },
                onSeeAllPostsClick: { viewModel.path.append(.allPosts) }
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
                            onAuthorClick: { user in
                                viewModel.path.append(.authorProfile(user: user))
                            }
                        )
                        
                    case let .readPost(postId):
                        ReadPostDestination(
                            postId: postId,
                            onBackClick: { viewModel.path.removeLast() }
                        )
                        .background(.appBackground)

                    case .allPosts:
                        AllPostsDestination(
                            onPostClick: { postId in
                                viewModel.path.append(.readPost(postId: postId))
                            }
                        )
                        .background(.appBackground)
                }
            }
        }
    }
}
