import SwiftUI

struct ReadAnnouncementDestination: View {
    let onAuthorClick: (User) -> Void
    let onBackClick: () -> Void
    
    @StateObject private var viewModel: ReadAnnouncementViewModel
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
        
    init(
        announcementId: String,
        onAuthorClick: @escaping (User) -> Void,
        onBackClick: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: NewsMainThreadInjector.shared.resolve(
                ReadAnnouncementViewModel.self,
                arguments: announcementId
            )!
        )
        self.onAuthorClick = onAuthorClick
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
            isPresented: $showErrorAlert,
            actions: {
                Button(stringResource(.ok)) {
                    showErrorAlert = false
                }
            }
        )
    }
}

private struct ReadAnnouncementView: View {
    let announcement: Announcement
    let user: User
    let loading: Bool
    let onDeleteAnnouncementClick: () -> Void
    let onReportAnnouncementClick: (AnnouncementReport) -> Void
    let onAuthorClick: (User) -> Void
    
    @State private var showDeleteAnnouncementAlert: Bool = false
    @State private var activeSheet: ReadAnnouncementViewSheet?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Dimens.mediumPadding) {
                AnnouncementHeader(
                    announcement: announcement,
                    onAuthorClick: { onAuthorClick(announcement.author) }
                )
                
                if let title = announcement.title {
                    Text(title)
                        .font(.titleMedium)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Text(announcement.content)
                    .font(.bodyMedium)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal)
        .loading(loading)
        .navigationTitle(stringResource(.announcement))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $activeSheet) {
            switch $0 {
                case .announcement:
                    AnnouncementSheet(
                        announcementState: announcement.state,
                        editable: user.admin && announcement.author.id == user.id,
                        onEditClick: {
                            activeSheet = .editAnnouncement
                        },
                        onDeleteClick: {
                            activeSheet = nil
                            showDeleteAnnouncementAlert = true
                        },
                        onReportClick: {
                            activeSheet = .announcementReport
                        }
                    )
                    
                case .announcementReport:
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
                    
                case .editAnnouncement:
                    EditAnnouncementDestination(
                        announcement: announcement,
                        onCancelClick: { activeSheet = nil }
                    )
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                OptionsButton(action: { activeSheet = .announcement })
            }
        }
        .alert(
            stringResource(.deleteAnnouncementAlertMessage),
            isPresented: $showDeleteAnnouncementAlert,
            actions: {
                Button(
                    stringResource(.cancel),
                    role: .cancel,
                    action: { showDeleteAnnouncementAlert = false }
                )
                
                Button(
                    stringResource(.delete), role: .destructive,
                    action: onDeleteAnnouncementClick
                )
            }
        )
    }
}

private enum ReadAnnouncementViewSheet: Identifiable {
    case announcement
    case announcementReport
    case editAnnouncement
    
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
        ReadAnnouncementView(
            announcement: announcementFixture,
            user: announcementFixture.author,
            loading: false,
            onDeleteAnnouncementClick: {},
            onReportAnnouncementClick: { _ in },
            onAuthorClick: { _ in }
        )
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
