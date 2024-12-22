import SwiftUI

struct AnnouncementDetailView: View {
    @Binding private var announcement: Announcement
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showErrorAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var showEditBottomSheet: Bool = false
    
    init(announcement: Binding<Announcement>) {
        self._announcement = announcement
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: GedSpacing.medium) {
                HStack {
                    TopAnnouncementDetailItem(announcement: announcement)
                        .padding(.top, 5)
                    if let currentUser = newsViewModel.currentUser {
                        if currentUser.isMember && announcement.author.id == currentUser.id {
                            Menu {
                                Button(
                                    action: { showEditBottomSheet = true },
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
                            .sheet(isPresented: $showEditBottomSheet) {
                                EditAnnouncementView(announcement: announcement)
                                    .environmentObject(newsViewModel)
                            }
                        }
                    }
                }.onReceive(newsViewModel.$announcementState) { state in
                    if case .deleted = state {
                        dismiss()
                    } else if case .error(let message) = state {
                        errorMessage = message
                        showErrorAlert = true
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
                    showErrorAlert = false
                }
                Button(getString(.delete), role: .destructive) {
                    Task {
                        await newsViewModel.deleteAnnouncement(announcement: announcement)
                    }
                }
            }
        }
    }
}

#Preview {
    AnnouncementDetailView(
        announcement: .constant(announcementFixture)
    ).environmentObject(DependencyContainer.shared.mockNewsViewModel)
}
