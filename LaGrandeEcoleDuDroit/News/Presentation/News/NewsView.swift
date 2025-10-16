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
                    Button(getString(.ok)) {
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
    let onCreateAnnouncementClick: () -> Void
    let onEditAnnouncementClick: (Announcement) -> Void
    let onResendAnnouncementClick: (Announcement) -> Void
    let onDeleteAnnouncementClick: (Announcement) -> Void
    let onReportAnnouncementClick: (AnnouncementReport) -> Void
    let onSeeAllAnnouncementClick: () -> Void
    
    @State private var showAnnouncementBottomSheet: Bool = false
    @State private var showAnnouncementReportBottomSheet: Bool = false
    @State private var showDeleteAnnouncementAlert: Bool = false
    @State private var clickedAnnouncement: Announcement?
    
    var body: some View {
        HStack {
            if let announcements {
                RecentAnnouncementSection(
                    announcements: announcements,
                    onAnnouncementClick: onAnnouncementClick,
                    onUncreatedAnnouncementClick: {
                        clickedAnnouncement = $0
                        showAnnouncementBottomSheet = true
                    },
                    onAnnouncementOptionClick: {
                        clickedAnnouncement = $0
                        showAnnouncementBottomSheet = true
                        
                    },
                    onSeeAllAnnouncementClick: onSeeAllAnnouncementClick
                )
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .refreshable { await onRefreshAnnouncements() }
        .padding(.top, GedSpacing.medium)
        .loading(loading)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Image(ImageResource.gedLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                    
                    Text(getString(.appName))
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                if user.isMember {
                    Button(
                        action: onCreateAnnouncementClick,
                        label: { Image(systemName: "plus") }
                    )
                }
            }
        }
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
            getString(.deleteAnnouncementAlertMessage),
            isPresented: $showDeleteAnnouncementAlert,
            actions: {
                Button(getString(.cancel), role: .cancel) {
                    showDeleteAnnouncementAlert = false
                }
                
                Button(getString(.delete), role: .destructive) {
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
                isEditable: user.isMember && clickedAnnouncement.author.id == user.id,
                onEditClick: { onEditAnnouncementClick(clickedAnnouncement) },
                onResendClick: { onResendAnnouncementClick(clickedAnnouncement) },
                onDeleteClick: onDeleteAnnouncementClick,
                onReportClick: onReportAnnouncementClick
            )
        } else {
            BottomSheetContainer(fraction: 0.16) {
                Text(getString(.unknownError))
                    .foregroundColor(.error)
            }
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
}
