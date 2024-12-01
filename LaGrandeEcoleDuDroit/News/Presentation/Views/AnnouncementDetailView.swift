import SwiftUI

struct AnnouncementDetailView: View {
    @Binding private var announcement: Announcement
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showErrorDialog: Bool = false
    @State private var showDeleteDialog: Bool = false
    @State private var errorMessage: String = ""
    @State private var showEditBottomSheet: Bool = false
    private var currentUser: User
    
    init(
        announcement: Binding<Announcement>,
        currentUser: User
    ) {
        self._announcement = announcement
        self.currentUser = currentUser
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: GedSpacing.medium) {
                HStack {
                    TopAnnouncementDetailItem(announcement: announcement)
                        .padding(.top, 5)
                    
                    if currentUser.isMember && announcement.author.id == currentUser.id {
                        Menu {
                            Button(
                                action: { showEditBottomSheet = true },
                                label: {
                                    Label(getString(gedString: GedString.edit), systemImage: "square.and.pencil")
                                }
                            )
                            Button(
                                role: .destructive,
                                action: { showDeleteDialog = true },
                                label: {
                                    Label(getString(gedString: GedString.delete), systemImage: "trash")
                                }
                            )
                        } label: {
                            Image(systemName: "ellipsis")
                                .imageScale(.large)
                                .padding(5)
                        }
                        .sheet(isPresented: $showEditBottomSheet) {
                            EditAnnouncementView(announcement: announcement)
                                .environmentObject(newsViewModel)
                        }
                    }
                }.onReceive(newsViewModel.$announcementState) { state in
                    if case .deleted = state {
                        dismiss()
                    } else if case .error(let message) = state {
                        errorMessage = message
                        showErrorDialog = true
                        newsViewModel.resetAnnouncementState()
                    }
                }
                
               if let title = announcement.title, !title.isEmpty {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
               }
               
                Text(announcement.content)
                    .font(.body)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal)
            .onAppear() {
                
                
            }
            .alert(
                "",
                isPresented: $showErrorDialog,
                presenting: ""
            ) { data in
                Button(getString(gedString: GedString.ok)) {
                    showErrorDialog = false
                    newsViewModel.resetAnnouncementState()
                }
            } message: { data in
                Text(errorMessage)
            }
            .alert(
                "",
                isPresented: $showDeleteDialog,
                presenting: ""
            ) { data in
                Button(getString(gedString: GedString.cancel), role: .cancel) {
                    showErrorDialog = false
                }
                Button(getString(gedString: GedString.delete), role: .destructive) {
                    Task {
                        await newsViewModel.deleteAnnouncement(announcement: announcement)
                    }
                }
            } message: { data in
                Text(getString(gedString: GedString.delete_announcemment_dialog_message))
            }
        }
    }
}

#Preview {
    AnnouncementDetailView(
        announcement: .constant(announcementFixture),
        currentUser: userFixture
    ).environmentObject(DependencyContainer.shared.newsViewModel)
}
