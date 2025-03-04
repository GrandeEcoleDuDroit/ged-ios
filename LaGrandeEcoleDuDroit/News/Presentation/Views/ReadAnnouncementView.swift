import SwiftUI

struct ReadAnnouncementView: View {
    @StateObject private var readAnnouncementViewModel: ReadAnnouncementViewModel
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var showErrorAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var errorMessage: String = ""
        
    init(announcement: Announcement) {
        _readAnnouncementViewModel = StateObject(
            wrappedValue: NewsInjection.shared.resolve(ReadAnnouncementViewModel.self, arguments: announcement)!
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            HStack {
                AnnouncementHeader(announcement: readAnnouncementViewModel.announcement)
                
                if let currentUser = readAnnouncementViewModel.currentUser {
                    if currentUser.isMember && readAnnouncementViewModel.announcement.author.id == currentUser.id {
                        Menu {
                            Button(
                                action: { navigationCoordinator.push(NewsScreen.editAnnouncement(readAnnouncementViewModel.announcement)) },
                                label: { Label(getString(.edit), systemImage: "square.and.pencil") }
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
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: GedSpacing.medium) {
                    if !readAnnouncementViewModel.announcement.title.isBlank {
                        Text(readAnnouncementViewModel.announcement.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Text(readAnnouncementViewModel.announcement.content)
                        .font(.bodyLarge)
                        .lineSpacing(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal)
        .loading(readAnnouncementViewModel.screenState == .loading)
        .alert(
            errorMessage,
            isPresented: $showErrorAlert
        ) {
            Button(getString(.ok)) {
                showErrorAlert = false
                readAnnouncementViewModel.resetAnnouncementState()
            }
        }
        .alert(
            getString(.deleteAnnouncementAlertTitle),
            isPresented: $showDeleteAlert
        ) {
            Button(getString(.cancel), role: .cancel) {
                showDeleteAlert = false
            }
            Button(getString(.delete), role: .destructive) {
                readAnnouncementViewModel.deleteAnnouncement()
            }
        }
        .onReceive(readAnnouncementViewModel.$screenState) { state in
            if case .deleted = state {
                navigationCoordinator.pop()
            } else if case .error(let message) = state {
                errorMessage = message
                showErrorAlert = true
                readAnnouncementViewModel.resetAnnouncementState()
            }
        }
    }
}


#Preview {
    NavigationStack {
        ReadAnnouncementView(announcement: announcementFixture)
            .environmentObject(NavigationCoordinator())
    }
}
