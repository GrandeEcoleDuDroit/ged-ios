import SwiftUI

struct NewsDestination: View {
    let onAnnouncementClick: (String) -> Void
    let onSeeAllAnnouncementsClick: () -> Void
    let onSeeAllPostsClick: () -> Void
    
    @StateObject private var viewModel = NewsMainThreadInjector.shared.resolve(NewsViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    
    var body: some View {
        if let user = viewModel.uiState.user {
            NewsView(
                user: user,
                announcements: viewModel.uiState.announcements,
                posts: viewModel.uiState.posts,
                loading: viewModel.uiState.loading,
                onRefreshAnnouncements: viewModel.refreshAnnouncements,
                onAnnouncementClick: onAnnouncementClick,
                onRecreateAnnouncementClick: viewModel.recreateAnnouncement,
                onDeleteAnnouncementClick: viewModel.deleteAnnouncement,
                onReportAnnouncementClick: viewModel.reportAnnouncement,
                onSeeAllAnnouncementsClick: onSeeAllAnnouncementsClick,
                getAnnouncement: viewModel.getAnnouncement,
                onSeeAllPostsClick: onSeeAllPostsClick,
                onRecreatePostClick: viewModel.recreatePost,
                onDeletePostClick: viewModel.deletePost
            )
            .onReceive(viewModel.$event) { event in
                if let errorEvent = event as? ErrorEvent {
                    errorMessage = errorEvent.message
                    showErrorAlert = true
                }
            }
            .alert(
                errorMessage,
                isPresented: $showErrorAlert,
                actions: {
                    Button(stringResource(.ok)) {
                        showErrorAlert = false
                    }
                }
            )
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

private struct NewsView: View {
    let user: User
    let announcements: [Announcement]?
    let posts: [Post]?
    let loading: Bool
    let onRefreshAnnouncements: () async -> Void
    let onAnnouncementClick: (String) -> Void
    let onRecreateAnnouncementClick: (Announcement) -> Void
    let onDeleteAnnouncementClick: (Announcement) -> Void
    let onReportAnnouncementClick: (AnnouncementReport) -> Void
    let onSeeAllAnnouncementsClick: () -> Void
    let getAnnouncement: (String) -> Announcement?
    let onSeeAllPostsClick: () -> Void
    let onRecreatePostClick: (Post) -> Void
    let onDeletePostClick: (Post) -> Void
    
    @State private var deleteAnnouncementAlert = AlertData<Announcement>(stringResource(.deleteAnnouncementAlertMessage))
    @State private var deletePostAlert = AlertData<Post>(stringResource(.deletePostAlertMessage))
    @State private var activeSheet:  NewsViewSheet?
    
    private static let announcementSectionFraction: CGFloat = 0.9
    private static let postSectionFraction: CGFloat = 1
    private static let totalSectionsFraction: CGFloat = announcementSectionFraction + postSectionFraction

    var body: some View {
        GeometryReader { geo in
            TimelineView(.periodic(from: .now, by: 60)) { _ in
                VStack(spacing: DimensResource.mediumPadding) {
                    AnnouncementSection(
                        announcements: announcements,
                        onAnnouncementClick: { announcement in
                            switch announcement.state {
                                case .published: onAnnouncementClick(announcement.id)
                                default: activeSheet = .announcement(announcement)
                            }
                        },
                        onAnnouncementOptionsClick: { announcement in
                            activeSheet = .announcement(announcement)
                        },
                        onSeeAllAnnouncementsClick: onSeeAllAnnouncementsClick,
                        onRefreshAnnouncements: onRefreshAnnouncements
                    )
                    .frame(height: geo.size.height * (NewsView.announcementSectionFraction / NewsView.totalSectionsFraction))
                    
                    PostSection(
                        posts: posts,
                        onPostClick: { _ in
                            // TODO
                        },
                        onUncreatedPostClick: { post in
                            activeSheet = .post(post)
                        },
                        onRedirectPostClick: { _ in
                            // TODO
                        },
                        onPostOptionClick: { post in
                            activeSheet = .post(post)
                        },
                        onSeeAllPostsClick: onSeeAllPostsClick
                    )
                    .padding(.bottom)
                    .frame(height: geo.size.height * (NewsView.postSectionFraction / NewsView.totalSectionsFraction))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.vertical)
        .loading(loading)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Image(ImageResource.appLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    
                    Text(stringResource(.appName))
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                if user.admin {
                    Menu(
                        content: {
                            Button(
                                stringResource(.newAnnouncement),
                                systemImage: "megaphone",
                                action: { activeSheet = .createAnnouncement }
                            )
                            
                            Button(
                                stringResource(.newPost),
                                systemImage: "newspaper",
                                action: { activeSheet = .createPost }
                            )
                        },
                        label: { Image(systemName: "plus") }
                    )
                }
            }
        }
        .sheet(item: $activeSheet) {
            switch $0 {
                case let .announcement(announcement):
                    AnnouncementSheet(
                        announcementState: announcement.state,
                        editable: user.admin && announcement.author.id == user.id,
                        onEditClick: {
                            if let fullAnnouncement = getAnnouncement(announcement.id) {
                                activeSheet = .editAnnouncement(fullAnnouncement)
                            } else {
                                activeSheet = nil
                            }
                        },
                        onRecreateClick: {
                            activeSheet = nil
                            onRecreateAnnouncementClick(announcement)
                        },
                        onDeleteClick: {
                            activeSheet = nil
                            deleteAnnouncementAlert.present(data: announcement)
                        },
                        onReportClick: {
                            activeSheet = .announcementReport(announcement)
                        }
                    )
                    
                case let .announcementReport(announcement):
                    ReportSheet(
                        items: AnnouncementReport.Reason.allCases,
                        onReportClick: { reason in
                            activeSheet = nil
                            onReportAnnouncementClick(
                                AnnouncementReport(
                                    announcementId: announcement.id,
                                    author: AnnouncementReport.Author(
                                        fullName: announcement.author.fullName,
                                        email: announcement.author.email
                                    ),
                                    reporter: AnnouncementReport.Reporter(
                                        fullName: user.fullName,
                                        email: user.email
                                    ),
                                    reason: reason
                                )
                            )
                        }
                    )
                    
                case .createAnnouncement:
                    CreateAnnouncementDestination(
                        onCancelClick: { activeSheet = nil }
                    )
                    
                case let .editAnnouncement(announcement):
                    EditAnnouncementDestination(
                        announcement: announcement,
                        onCancelClick: { activeSheet = nil }
                    )
                    
                case let .post(post):
                    PostSheet(
                        postState: post.state,
                        editable: user.admin,
                        onEditClick: {
                            activeSheet = .editPost(post)
                        },
                        onRecreateClick: {
                            activeSheet = nil
                            onRecreatePostClick(post)
                        },
                        onDeleteClick: {
                            activeSheet = nil
                            deletePostAlert.present(data: post)
                        },
                        onReportClick: {
                            // TODO
                        }
                    )

                case .createPost:
                    CreatePostDestination(
                        onCancelClick: { activeSheet = nil }
                    )
                    
                case let .editPost(post):
                    EditPostDestination(
                        post: post,
                        onCancelClick: { activeSheet = nil }
                    )
            }
        }
        .alert(
            deleteAnnouncementAlert.title,
            isPresented: $deleteAnnouncementAlert.presented,
            presenting: deleteAnnouncementAlert.data,
            actions: { announcement in
                Button(stringResource(.cancel), role: .cancel) {
                    deleteAnnouncementAlert.dismiss()
                }
                
                Button(stringResource(.delete), role: .destructive) {
                    onDeleteAnnouncementClick(announcement)
                    deleteAnnouncementAlert.dismiss()
                }
            }
        )
        .alert(
            deletePostAlert.title,
            isPresented: $deletePostAlert.presented,
            presenting: deletePostAlert.data,
            actions: { post in
                Button(stringResource(.cancel), role: .cancel) {
                    deletePostAlert.dismiss()
                }
                
                Button(stringResource(.delete), role: .destructive) {
                    onDeletePostClick(post)
                    deletePostAlert.dismiss()
                }
            }
        )
    }
}

private enum NewsViewSheet: Identifiable {
    case announcement(Announcement)
    case announcementReport(Announcement)
    case createAnnouncement
    case editAnnouncement(Announcement)
    case post(Post)
    case createPost
    case editPost(Post)
    
    var id: Int {
        switch self {
            case .announcement: 0
            case .announcementReport: 1
            case .createAnnouncement: 2
            case .editAnnouncement: 3
            case .post: 4
            case .createPost: 5
            case .editPost: 6
        }
    }
}

#Preview {
   NavigationStack {
       NewsView(
            user: userFixture,
            announcements: announcementsFixture,
            posts: postsFixture,
            loading: false,
            onRefreshAnnouncements: {},
            onAnnouncementClick: {_ in },
            onRecreateAnnouncementClick: {_ in },
            onDeleteAnnouncementClick: {_ in },
            onReportAnnouncementClick: {_ in },
            onSeeAllAnnouncementsClick: {},
            getAnnouncement: { _ in nil },
            onSeeAllPostsClick: {},
            onRecreatePostClick: { _ in },
            onDeletePostClick: { _ in }
       )
       .background(.appBackground)
   }
   .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
