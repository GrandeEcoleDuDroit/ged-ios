import SwiftUI

struct NewsDestination: View {
    let onAnnouncementClick: (String) -> Void
    let onCreateAnnouncementClick: () -> Void
    let onEditAnnouncementClick: (Announcement) -> Void
    let onSeeAllAnnouncementClick: () -> Void
    
    @StateObject private var viewModel = NewsMainThreadInjector.shared.resolve(NewsViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    
    var body: some View {
        if let user = viewModel.uiState.user {
            NewsView(
                user: user,
                announcements: viewModel.uiState.announcements,
                loading: viewModel.uiState.loading,
                onRefreshAnnouncements: viewModel.refreshAnnouncements,
                onAnnouncementClick: onAnnouncementClick,
                onCreateAnnouncementClick: onCreateAnnouncementClick,
                onEditAnnouncementClick: onEditAnnouncementClick,
                onResendAnnouncementClick: viewModel.resendAnnouncement,
                onDeleteAnnouncementClick: viewModel.deleteAnnouncement,
                onReportAnnouncementClick: viewModel.reportAnnouncement,
                onSeeAllAnnouncementClick: onSeeAllAnnouncementClick
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top)
        }
    }
}

private struct NewsView: View {
    let user: User
    let announcements: [Announcement]?
    let loading: Bool
    let onRefreshAnnouncements: () async -> Void
    let onAnnouncementClick: (String) -> Void
    let onCreateAnnouncementClick: () -> Void
    let onEditAnnouncementClick: (Announcement) -> Void
    let onResendAnnouncementClick: (Announcement) -> Void
    let onDeleteAnnouncementClick: (Announcement) -> Void
    let onReportAnnouncementClick: (AnnouncementReport) -> Void
    let onSeeAllAnnouncementClick: () -> Void
    
    @State private var showDeleteAnnouncementAlert: Bool = false
    @State private var announcementBottomSheetType:  AnnouncementBottomSheetType?
    @State private var alertAnnouncement: Announcement?
    
    var body: some View {
        ZStack {
            if let announcements {
                RecentAnnouncementSection(
                    announcements: announcements,
                    onAnnouncementClick: onAnnouncementClick,
                    onUncreatedAnnouncementClick: {
                        announcementBottomSheetType = .announcement(announcement: $0)
                    },
                    onAnnouncementOptionClick: {
                        announcementBottomSheetType = .announcement(announcement: $0)
                    },
                    onSeeAllAnnouncementClick: onSeeAllAnnouncementClick
                )
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .refreshable { await onRefreshAnnouncements() }
        .padding(.top)
        .loading(loading)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Image(ImageResource.gedLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                    
                    Text(stringResource(.appName))
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                if user.admin {
                    Button(
                        action: onCreateAnnouncementClick,
                        label: { Image(systemName: "plus") }
                    )
                }
            }
        }
        .sheet(item: $announcementBottomSheetType) {
            switch $0 {
                case let .announcement(announcement):
                    BottomSheet(
                        user: user,
                        announcement: announcement,
                        onResendAnnouncementClick: {
                            announcementBottomSheetType = nil
                            onResendAnnouncementClick($0)
                        },
                        onDeleteAnnouncementClick: {
                            announcementBottomSheetType = nil
                            alertAnnouncement = announcement
                            showDeleteAnnouncementAlert = true
                        },
                        onEditAnnouncementClick: {
                            announcementBottomSheetType = nil
                            onEditAnnouncementClick($0)
                        },
                        onReportAnnouncementClick: {
                            announcementBottomSheetType = .report(announcement: announcement)
                        }
                    )
                    
                case let .report(announcement):
                    ReportBottomSheet(
                        items: AnnouncementReport.Reason.allCases,
                        fraction: Dimens.titleBottomSheetFraction(itemCount: AnnouncementReport.Reason.allCases.count),
                        onReportClick: { reason in
                            announcementBottomSheetType = nil
                            onReportAnnouncementClick(
                                AnnouncementReport(
                                    announcementId: announcement.id,
                                    authorInfo: AnnouncementReport.UserInfo(
                                        fullName: user.fullName,
                                        email: user.email
                                    ),
                                    userInfo: AnnouncementReport.UserInfo(
                                        fullName: announcement.author.fullName,
                                        email: announcement.author.email
                                    ),
                                    reason: reason
                                )
                            )
                        }
                    )
            }
        }
        .alert(
            stringResource(.deleteAnnouncementAlertMessage),
            isPresented: $showDeleteAnnouncementAlert,
            presenting: alertAnnouncement,
            actions: { announcement in
                Button(stringResource(.cancel), role: .cancel) {
                    alertAnnouncement = nil
                    showDeleteAnnouncementAlert = false
                }
                
                Button(stringResource(.delete), role: .destructive) {
                    onDeleteAnnouncementClick(announcement)
                    alertAnnouncement = nil
                    showDeleteAnnouncementAlert = false
                }
            }
        )
    }
}

private struct BottomSheet: View {
    let user: User
    let announcement: Announcement
    let onResendAnnouncementClick: (Announcement) -> Void
    let onDeleteAnnouncementClick: () -> Void
    let onEditAnnouncementClick: (Announcement) -> Void
    let onReportAnnouncementClick: () -> Void
    
    var body: some View {
        AnnouncementBottomSheet(
            announcement: announcement,
            isEditable: user.admin && announcement.author.id == user.id,
            onEditClick: { onEditAnnouncementClick(announcement) },
            onResendClick: { onResendAnnouncementClick(announcement) },
            onDeleteClick: onDeleteAnnouncementClick,
            onReportClick: onReportAnnouncementClick
        )
    }
}

private enum AnnouncementBottomSheetType: Identifiable {
    case announcement(announcement: Announcement)
    case report(announcement: Announcement)
    
    var id: Int {
        switch self {
            case .announcement: 1
            case .report: 2
        }
    }
}

#Preview {
   NavigationStack {
       NewsView(
            user: userFixture,
            announcements: announcementsFixture,
            loading: false,
            onRefreshAnnouncements: {},
            onAnnouncementClick: {_ in },
            onCreateAnnouncementClick: {},
            onEditAnnouncementClick: {_ in },
            onResendAnnouncementClick: {_ in },
            onDeleteAnnouncementClick: {_ in },
            onReportAnnouncementClick: {_ in },
            onSeeAllAnnouncementClick: {}
       )
       .background(Color.background)
   }
   .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
