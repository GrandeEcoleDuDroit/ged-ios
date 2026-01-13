import SwiftUI

struct NewsDestination: View {
    let onAnnouncementClick: (String) -> Void
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
                onResendAnnouncementClick: viewModel.recreateAnnouncement,
                onDeleteAnnouncementClick: viewModel.deleteAnnouncement,
                onReportAnnouncementClick: viewModel.reportAnnouncement,
                onSeeAllAnnouncementClick: onSeeAllAnnouncementClick,
                getAnnouncement: viewModel.getAnnouncement
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
    let loading: Bool
    let onRefreshAnnouncements: () async -> Void
    let onAnnouncementClick: (String) -> Void
    let onResendAnnouncementClick: (Announcement) -> Void
    let onDeleteAnnouncementClick: (Announcement) -> Void
    let onReportAnnouncementClick: (AnnouncementReport) -> Void
    let onSeeAllAnnouncementClick: () -> Void
    let getAnnouncement: (String) -> Announcement?
    
    @State private var showDeleteAnnouncementAlert: Bool = false
    @State private var alertAnnouncement: Announcement?
    @State private var activeSheet:  NewsViewSheet?

    var body: some View {
        RecentAnnouncementSection(
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
            onSeeAllAnnouncementClick: onSeeAllAnnouncementClick,
            onRefreshAnnouncements: onRefreshAnnouncements
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top)
        .loading(loading)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Image(ImageResource.gedLogo)
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
                    Button(
                        action: { activeSheet = .createAnnouncement },
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
                        onResendClick: {
                            activeSheet = nil
                            onResendAnnouncementClick(announcement)
                        },
                        onDeleteClick: {
                            activeSheet = nil
                            alertAnnouncement = announcement
                            showDeleteAnnouncementAlert = true
                        },
                        onReportClick: {
                            activeSheet = .announcementReport(announcement)
                        }
                    )
                    
                case let .announcementReport(announcement):
                    ReportSheet(
                        items: AnnouncementReport.Reason.allCases,
                        fraction: DimensResource.reportSheetFraction(itemCount: AnnouncementReport.Reason.allCases.count),
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

private enum NewsViewSheet: Identifiable {
    case announcement(Announcement)
    case announcementReport(Announcement)
    case createAnnouncement
    case editAnnouncement(Announcement)
    
    var id: Int {
        switch self {
            case .announcement: 0
            case .announcementReport: 1
            case .createAnnouncement: 2
            case .editAnnouncement: 3
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
            onResendAnnouncementClick: {_ in },
            onDeleteAnnouncementClick: {_ in },
            onReportAnnouncementClick: {_ in },
            onSeeAllAnnouncementClick: {},
            getAnnouncement: { _ in nil }
       )
       .background(.appBackground)
   }
   .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
