import SwiftUI

struct ReadAnnouncementDestination: View {
    let onAuthorClick: (User) -> Void
    let onEditAnnouncementClick: (Announcement) -> Void
    let onBackClick: () -> Void
    
    @StateObject private var viewModel: ReadAnnouncementViewModel
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
        
    init(
        announcementId: String,
        onAuthorClick: @escaping (User) -> Void,
        onEditAnnouncementClick: @escaping (Announcement) -> Void,
        onBackClick: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: NewsMainThreadInjector.shared.resolve(
                ReadAnnouncementViewModel.self,
                arguments: announcementId
            )!
        )
        self.onAuthorClick = onAuthorClick
        self.onEditAnnouncementClick = onEditAnnouncementClick
        self.onBackClick = onBackClick
    }
    
    var body: some View {
        ZStack {
            if let announcement = viewModel.uiState.announcement,
               let user = viewModel.uiState.user {
                ReadAnnouncementView(
                    announcement: announcement,
                    user: user,
                    loading: viewModel.uiState.loading,
                    onEditAnnouncementClick: onEditAnnouncementClick,
                    onDeleteAnnouncementClick: viewModel.deleteAnnouncement,
                    onReportAnnouncementClick: viewModel.reportAnnouncement,
                    onAuthorClick: onAuthorClick
                )
            }
        }
        .onReceive(viewModel.$event) { event in
            if let errorEvent = event as? ErrorEvent {
                errorMessage = errorEvent.message
                showErrorAlert = true
            } else if let _ = event as? SuccessEvent {
                onBackClick()
            }
        }
        .alert(
            errorMessage,
            isPresented: $showErrorAlert
        ) {
            Button(getString(.ok)) {
                showErrorAlert = false
            }
        }
    }
}

private struct ReadAnnouncementView: View {
    let announcement: Announcement
    let user: User
    let loading: Bool
    let onEditAnnouncementClick: (Announcement) -> Void
    let onDeleteAnnouncementClick: () -> Void
    let onReportAnnouncementClick: (AnnouncementReport) -> Void
    let onAuthorClick: (User) -> Void
    
    @State private var showDeleteAlert: Bool = false
    @State private var showBottomSheet: Bool = false
    @State private var showReportBottomSheet: Bool = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: GedSpacing.medium) {
                AnnouncementHeader(
                    announcement: announcement,
                    onAuthorClick: { onAuthorClick(announcement.author) }
                )
                
                if let title = announcement.title {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Text(announcement.content)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal)
        .loading(loading)
        .navigationTitle(getString(.announcement))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                OptionButton { showBottomSheet = true }
            }
        }
        .sheet(isPresented: $showBottomSheet) {
            AnnouncementBottomSheet(
                isEditable: user.isMember && announcement.author.id == user.id,
                onEditClick: {
                    showBottomSheet = false
                    onEditAnnouncementClick(announcement)
                },
                onDeleteClick: {
                    showBottomSheet = false
                    showDeleteAlert = true
                },
                onReportClick: {
                    showBottomSheet = false
                    showReportBottomSheet = true
                }
            )
        }
        .sheet(isPresented: $showReportBottomSheet) {
            ReportBottomSheet(
                items: AnnouncementReport.Reason.allCases,
                fraction: 0.45,
                onReportClick: { reason in
                    showReportBottomSheet = false
                    
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
        .alert(
            getString(.deleteAnnouncementAlertTitle),
            isPresented: $showDeleteAlert
        ) {
            Button(
                getString(.cancel),
                role: .cancel,
                action: { showDeleteAlert = false }
            )
            Button(
                getString(.delete), role: .destructive,
                action: onDeleteAnnouncementClick
            )
        }
    }
}

#Preview {
    NavigationStack {
        ReadAnnouncementView(
            announcement: announcementFixture,
            user: userFixture2,
            loading: false,
            onEditAnnouncementClick: { _ in },
            onDeleteAnnouncementClick: {},
            onReportAnnouncementClick: { _ in },
            onAuthorClick: { _ in }
        )
        .background(Color.background)
    }
}
