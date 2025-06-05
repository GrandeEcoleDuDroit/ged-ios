import SwiftUI

struct ReadAnnouncementDestination: View {
    let onEditAnnouncementClick: (Announcement) -> Void
    let onBackClick: () -> Void
    
    @StateObject private var viewModel: ReadAnnouncementViewModel
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
        
    init(
        announcementId: String,
        onEditAnnouncementClick: @escaping (Announcement) -> Void,
        onBackClick: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: NewsInjection.shared.resolve(ReadAnnouncementViewModel.self, arguments: announcementId)!
        )
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
                    onDeleteAnnouncementClick: viewModel.deleteAnnouncement
                )
            }
        }
        .navigationTitle(getString(.announcement))
        .navigationBarTitleDisplayMode(.inline)
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
    
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            HStack {
                AnnouncementHeader(announcement: announcement)
                
                if user.isMember && announcement.author.id == user.id {
                    Menu {
                        Button(
                            action: { onEditAnnouncementClick(announcement) },
                            label: {
                                Label(getString(.edit), systemImage: "square.and.pencil")
                            }
                        )
                        
                        Button(
                            role: .destructive,
                            action: { showDeleteAlert = true },
                            label: { Label(getString(.delete), systemImage: "trash") }
                        )
                    } label: {
                        Image(systemName: "ellipsis")
                            .imageScale(.large)
                            .padding(5)
                    }
                }
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: GedSpacing.medium) {
                    if let title = announcement.title, !title.isBlank {
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal)
        .loading(loading)
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
            user: userFixture,
            loading: false,
            onEditAnnouncementClick: { _ in },
            onDeleteAnnouncementClick: {}
        )
    }
}
