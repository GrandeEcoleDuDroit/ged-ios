import SwiftUI

struct AnnouncementDetailView: View {
    @StateObject private var announcementDetailViewModel: AnnouncementDetailViewModel
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @State private var showErrorAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var editMode: Bool = false
        
    init(announcement: Announcement) {
        _announcementDetailViewModel = StateObject(wrappedValue: NewsInjection.shared.resolve(AnnouncementDetailViewModel.self, arguments: announcement)!)
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
                TopAnnouncementDetailItem(announcement: announcementDetailViewModel.announcement)
                
                if let currentUser = announcementDetailViewModel.currentUser {
                    if currentUser.isMember && announcementDetailViewModel.announcement.author.id == currentUser.id {
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
                    Text(announcementDetailViewModel.announcement.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(announcementDetailViewModel.announcement.content)
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
                announcementDetailViewModel.resetAnnouncementState()
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
                announcementDetailViewModel.deleteAnnouncement()
            }
        }
        .onReceive(announcementDetailViewModel.$announcementState) { state in
            if case .deleted = state {
                announcementDetailViewModel.resetAnnouncementState()
                coordinator.pop()
            } else if case .error(let message) = state {
                errorMessage = message
                showErrorAlert = true
                announcementDetailViewModel.resetAnnouncementState()
            }
        }
    }
    
    var editAnnouncement: some View {
        EditAnnouncementView(
            announcement: announcementDetailViewModel.announcement,
            onCancelClick: {
                editMode = false
            },
            onSaveClick: { title, content in
                announcementDetailViewModel.updateAnnouncement(
                    announcement: announcementDetailViewModel.announcement.with(title: title, content: content, date: .now)
                )
            }
        )
        .onReceive(announcementDetailViewModel.$announcementState) { state in
            if case .updated = state {
                editMode = false
            }
        }
        .environmentObject(announcementDetailViewModel)
    }
}


#Preview {
    NavigationStack {
        AnnouncementDetailView(announcement: announcementFixture)
            .environmentObject(NavigationCoordinator())
    }
}
