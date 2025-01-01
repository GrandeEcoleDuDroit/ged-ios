import SwiftUI

struct AnnouncementDetailView: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @State private var showErrorAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var editMode: Bool = false
    private var announcement: Announcement
    
    init(announcement: Announcement) {
        self.announcement = announcement
    }
    
    var body: some View {
        HStack {
            if editMode {
                editAnnouncement
            } else {
                readAnnouncement
            }
        }
        .navigationBarBackButtonHidden(editMode)
    }
    
    var readAnnouncement: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            HStack {
                TopAnnouncementDetailItem(announcement: announcement)
                
                if let currentUser = newsViewModel.currentUser {
                    if currentUser.isMember && announcement.author.id == currentUser.id {
                        Menu {
                            Button(
                                action: { editMode = true },
                                label: {
                                    Label(getString(.edit), systemImage: "square.and.pencil")
                                }
                            )
                            
                            Button(
                                role: .destructive,
                                action: { showDeleteAlert = true },
                                label: {
                                    Label(getString(.delete), systemImage: "trash")
                                }
                            )
                        } label: {
                            Image(systemName: "ellipsis")
                                .imageScale(.large)
                                .padding(5)
                        }
                    }
                }
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: GedSpacing.medium) {
                    if let title = announcement.title, !title.isEmpty {
                        Text(title)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Text(announcement.content)
                        .font(.bodyLarge)
                        .lineSpacing(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal)
        .alert(
            errorMessage,
            isPresented: $showErrorAlert
        ) {
            Button(getString(.ok)) {
                showErrorAlert = false
                newsViewModel.resetAnnouncementState()
            }
        }
        .alert(
            getString(.deleteAnnouncementAlertMessage),
            isPresented: $showDeleteAlert
        ) {
            Button(getString(.cancel), role: .cancel) {
                showDeleteAlert = false
            }
            Button(getString(.delete), role: .destructive) {
                newsViewModel.deleteAnnouncement(announcement: announcement)
            }
        }
        .onReceive(newsViewModel.$announcementState) { state in
            if case .deleted = state {
                newsViewModel.resetAnnouncementState()
                coordinator.pop()
            } else if case .error(let message) = state {
                errorMessage = message
                showErrorAlert = true
                newsViewModel.resetAnnouncementState()
            }
        }
    }
    
    var editAnnouncement: some View {
        EditAnnouncementView(
            announcement: announcement,
            onCancelClick: {
                editMode = false
            },
            onSaveClick: { title, content in
                newsViewModel.updateAnnouncement(
                    announcement: announcement.with(title: title, content: content, date: .now)
                )
            }
        )
        .onReceive(newsViewModel.$announcementState) { state in
            if case .updated = state {
                editMode = false
            }
        }
        .environmentObject(newsViewModel)
    }
}


#Preview {
    NavigationStack {
        AnnouncementDetailView(announcement: announcementFixture)
            .environmentObject(DependencyContainer.shared.mockNewsViewModel)
            .environmentObject(NavigationCoordinator())
    }
}
