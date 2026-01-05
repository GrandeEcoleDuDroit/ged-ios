import SwiftUI

struct AllAnnouncementsDestination: View {
    let onAnnouncementClick: (String) -> Void
    let onAuthorClick: (User) -> Void
    
    @StateObject private var viewModel = NewsMainThreadInjector.shared.resolve(AllAnnouncementsViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    
    var body: some View {
        if let user = viewModel.uiState.user {
            AllAnnouncementsView(
                user: user,
                announcements: viewModel.uiState.announcements,
                loading: viewModel.uiState.loading,
                onRefresh: viewModel.refreshAnnouncements,
                onAuthorClick: onAuthorClick,
                onAnnouncementClick: onAnnouncementClick,
                onResendAnnouncementClick: { viewModel.recreateAnnouncement(announcement: $0) },
                onReportAnnouncementClick: { viewModel.reportAnnouncement(report: $0) },
                onDeleteAnnouncementClick: { viewModel.deleteAnnouncement(announcement: $0) }
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

private struct AllAnnouncementsView: View {
    let user: User
    let announcements: [Announcement]?
    let loading: Bool
    let onRefresh: () async -> Void
    let onAuthorClick: (User) -> Void
    let onAnnouncementClick: (String) -> Void
    let onResendAnnouncementClick: (Announcement) -> Void
    let onReportAnnouncementClick: (AnnouncementReport) -> Void
    let onDeleteAnnouncementClick: (Announcement) -> Void
    
    @State private var activeSheet: AllAnnouncementViewSheet?
    @State private var showDeleteAnnouncementAlert: Bool = false
    @State private var alertAnnouncement: Announcement?
    
    var body: some View {
        Group {
            if let announcements {
                PlainTableView(
                    modifier: PlainTableModifier(
                        backgroundColor: .appBackground,
                        separatorStyle: .singleLine,
                        onRefresh: onRefresh
                    ),
                    values: announcements,
                    onRowClick: { announcement in
                        if announcement.state == .published {
                            onAnnouncementClick(announcement.id)
                        } else {
                            activeSheet = .announcement(announcement)
                        }
                    },
                    emptyContent: {
                        Text(stringResource(.noAnnouncement))
                            .foregroundStyle(.informationText)
                    },
                    content: { announcement in
                        ExtendedAnnouncementItem(
                            announcement: announcement,
                            onOptionsClick: { activeSheet = .announcement(announcement) },
                            onAuthorClick: { onAuthorClick(announcement.author) }
                        )
                    }
                )
            } else {
                ProgressView()
                    .padding(.top)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background(.appBackground)
            }
        }
        .loading(loading)
        .navigationTitle(stringResource(.allAnnouncements))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $activeSheet) {
            switch $0 {
                case let .announcement(announcement):
                    AnnouncementSheet(
                        announcementState: announcement.state,
                        editable: user.admin && announcement.author.id == user.id,
                        onEditClick: {
                            activeSheet = .editAnnouncement(announcement)
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
                        fraction: Dimens.reportSheetFraction(itemCount: AnnouncementReport.Reason.allCases.count),
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
                    showDeleteAnnouncementAlert = false
                }
                
                Button(stringResource(.delete), role: .destructive) {
                    onDeleteAnnouncementClick(announcement)
                    showDeleteAnnouncementAlert = false
                }
            }
        )
    }
}

private enum AllAnnouncementViewSheet: Identifiable {
    case announcement(Announcement)
    case announcementReport(Announcement)
    case editAnnouncement(Announcement)
    
    var id: Int {
        switch self {
            case .announcement: 0
            case .announcementReport: 1
            case .editAnnouncement: 2
        }
    }
}

#Preview {
    NavigationStack {
        AllAnnouncementsView(
            user: userFixture,
            announcements: announcementsFixture,
            loading: false,
            onRefresh: {},
            onAuthorClick: { _ in },
            onAnnouncementClick: { _ in },
            onResendAnnouncementClick: { _ in },
            onReportAnnouncementClick: { _ in },
            onDeleteAnnouncementClick: {  _ in }
        )
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
