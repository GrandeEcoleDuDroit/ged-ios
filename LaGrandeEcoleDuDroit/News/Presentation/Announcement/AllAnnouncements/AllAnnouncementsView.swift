import SwiftUI

struct AllAnnouncementsDestination: View {
    let onAnnouncementClick: (String) -> Void
    let onAuthorClick: (User) -> Void
    
    @StateObject private var viewModel = NewsMainThreadInjector.shared.resolve(AllAnnouncementsViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    
    var body: some View {
        if let user = viewModel.uiState.user, let announcements = viewModel.uiState.announcements {
            AllAnnouncementsView(
                user: user,
                announcements: announcements,
                loading: viewModel.uiState.loading,
                onRefresh: viewModel.refreshAnnouncements,
                onAuthorClick: onAuthorClick,
                onAnnouncementClick: onAnnouncementClick,
                onResendAnnouncementClick: { viewModel.resendAnnouncement(announcement: $0) },
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
    let announcements: [Announcement]
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
    @State private var selectedAnnouncement: Announcement?
    
    var body: some View {
        List {
            if announcements.isEmpty {
                Text(stringResource(.noAnnouncement))
                    .foregroundStyle(.informationText)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else {
                ForEach(announcements) { announcement in
                    ExtendedAnnouncementItem(
                        announcement: announcement,
                        onOptionsClick: {
                            activeSheet = .announcement(announcement)
                        },
                        onAuthorClick: { onAuthorClick(announcement.author) },
                    )
                    .contentShape(.rect)
                    .listRowTap(
                        value: announcement,
                        selectedItem: $selectedAnnouncement
                    ) {
                        if announcement.state == .published {
                            onAnnouncementClick(announcement.id)
                        } else {
                            activeSheet = .announcement(announcement)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(selectedAnnouncement == announcement ? Color.click : Color.clear)
                }
            }
        }
        .listStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .refreshable { await onRefresh() }
        .loading(loading)
        .navigationTitle(stringResource(.allAnnouncements))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $activeSheet) {
            switch $0 {
                case let .announcement(announcement):
                    AnnouncementSheet(
                        announcement: announcement,
                        isEditable: user.admin && announcement.author.id == user.id,
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
            announcements: announcementsFixture + announcementsFixture,
            loading: false,
            onRefresh: {},
            onAuthorClick: { _ in },
            onAnnouncementClick: { _ in },
            onResendAnnouncementClick: { _ in },
            onReportAnnouncementClick: { _ in },
            onDeleteAnnouncementClick: {  _ in }
        )
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
