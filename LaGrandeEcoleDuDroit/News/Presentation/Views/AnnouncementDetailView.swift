import SwiftUI

struct AnnouncementDetailView: View {
    @Binding var announcement: Announcement
    @Binding var newsViewModel: NewsViewModel
    private var currentUser: User
    
    init(
        announcement: Binding<Announcement>,
        newsViewModel: Binding<NewsViewModel>,
        currentUser: User
    ) {
        self._announcement = announcement
        self.currentUser = currentUser
        self._newsViewModel = newsViewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: GedSpacing.medium) {
                HStack {
                    TopAnnouncementDetailItem(announcement: $announcement)
                    if currentUser.isMember && announcement.author.id == currentUser.id {
                        Menu {
                            Button(
                                action: {
                                    print("Option 2 sélectionnée")
                                },
                                label: {
                                    Label(getString(gedString: GedString.modify), systemImage: "square.and.pencil")
                                }
                            )
                            Button(
                                action: {
                                    // Add delete anouncement
                                },
                                label: {
                                    Label(getString(gedString: GedString.delete), systemImage: "trash")
                                        
                                }
                            )
                        } label: {
                            Image(systemName: "ellipsis")
                                .imageScale(.large)
                        }
                    }
                }
                
                if let title = announcement.title {
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
        }
    }
}

#Preview {
    AnnouncementDetailView(
        announcement: .constant(announcementFixture),
        currentUser: userFixture
    )
}
