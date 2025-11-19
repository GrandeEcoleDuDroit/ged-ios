import SwiftUI

struct AllAnnouncementsDestination: View {
    let onAnnouncementClick: (String) -> Void
    let onEditAnnouncementClick: (Announcement) -> Void
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
                onEditAnnouncementClick: onEditAnnouncementClick,
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
    let onEditAnnouncementClick: (Announcement) -> Void
    let onReportAnnouncementClick: (AnnouncementReport) -> Void
    let onDeleteAnnouncementClick: (Announcement) -> Void
    
    @State private var showAnnouncementBottomSheet: Bool = false
    @State private var showAnnouncementReportBottomSheet: Bool = false
    @State private var showDeleteAnnouncementAlert: Bool = false
    @State private var clickedAnnouncement: Announcement?
    
    var body: some View {
        List {
            if announcements.isEmpty {
                Text(stringResource(.noAnnouncement))
                    .foregroundStyle(.informationText)
                    .padding()
                    .listRowBackground(Color.background)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(announcements) { announcement in
                    ExtendedAnnouncementItem(
                        announcement: announcement,
                        onClick: {
                            if announcement.state == .published {
                                onAnnouncementClick(announcement.id)
                            } else {
                                clickedAnnouncement = announcement
                                showAnnouncementBottomSheet = true
                            }
                        },
                        onOptionClick: {
                            clickedAnnouncement = announcement
                            showAnnouncementBottomSheet = true
                        },
                        onAuthorClick: { onAuthorClick(announcement.author) },
                    )
                    .listRowInsets(EdgeInsets())
                    .listSectionSeparator(.hidden)
                }
                .listRowBackground(Color.background)
            }
        }
        .scrollIndicators(.hidden)
        .listStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .refreshable { await onRefresh() }
        .loading(loading)
        .navigationTitle(stringResource(.allAnnouncements))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAnnouncementBottomSheet) {
            Sheet(
                user: user,
                clickedAnnouncement: $clickedAnnouncement,
                onResendAnnouncementClick: {
                    showAnnouncementBottomSheet = false
                    onResendAnnouncementClick($0)
                },
                onDeleteAnnouncementClick: {
                    showAnnouncementBottomSheet = false
                    showDeleteAnnouncementAlert = true
                },
                onEditAnnouncementClick: {
                    showAnnouncementBottomSheet = false
                    onEditAnnouncementClick($0)
                },
                onReportAnnouncementClick: {
                    showAnnouncementBottomSheet = false
                    showAnnouncementReportBottomSheet = true
                }
            )
        }
        .sheet(isPresented: $showAnnouncementReportBottomSheet) {
            ReportBottomSheet(
                items: AnnouncementReport.Reason.allCases,
                fraction: 0.45,
                onReportClick: { reason in
                    showAnnouncementReportBottomSheet = false
                    
                    if let clickedAnnouncement {
                        onReportAnnouncementClick(
                            AnnouncementReport(
                                announcementId: clickedAnnouncement.id,
                                authorInfo: AnnouncementReport.UserInfo(
                                    fullName: user.fullName,
                                    email: user.email
                                ),
                                userInfo: AnnouncementReport.UserInfo(
                                    fullName: clickedAnnouncement.author.fullName,
                                    email: clickedAnnouncement.author.email
                                ),
                                reason: reason
                            )
                        )
                    }
                }
            )
        }
        .alert(
            stringResource(.deleteAnnouncementAlertMessage),
            isPresented: $showDeleteAnnouncementAlert,
            actions: {
                Button(stringResource(.cancel), role: .cancel) {
                    showDeleteAnnouncementAlert = false
                }
                
                Button(stringResource(.delete), role: .destructive) {
                    if let clickedAnnouncement {
                        onDeleteAnnouncementClick(clickedAnnouncement)
                    }
                    showDeleteAnnouncementAlert = false
                }
            }
        )
    }
}

private struct Sheet: View {
    let user: User
    @Binding var clickedAnnouncement: Announcement?
    let onResendAnnouncementClick: (Announcement) -> Void
    let onDeleteAnnouncementClick: () -> Void
    let onEditAnnouncementClick: (Announcement) -> Void
    let onReportAnnouncementClick: () -> Void
    
    var body: some View {
        if let clickedAnnouncement {
            AnnouncementBottomSheet(
                announcement: clickedAnnouncement,
                isEditable: user.admin && clickedAnnouncement.author.id == user.id,
                onEditClick: { onEditAnnouncementClick(clickedAnnouncement) },
                onResendClick: { onResendAnnouncementClick(clickedAnnouncement) },
                onDeleteClick: onDeleteAnnouncementClick,
                onReportClick: onReportAnnouncementClick
            )
        } else {
            BottomSheetContainer(fraction: 0.16) {
                Text(stringResource(.unknownError))
                    .foregroundColor(.error)
            }
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
            onEditAnnouncementClick: { _ in },
            onReportAnnouncementClick: { _ in },
            onDeleteAnnouncementClick: {  _ in }
        )
        .background(Color.background)
    }
}
