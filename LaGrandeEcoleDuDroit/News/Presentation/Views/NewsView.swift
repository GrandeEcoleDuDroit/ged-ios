import SwiftUI

struct NewsView: View {
    @StateObject private var newsViewModel: NewsViewModel = DependencyContainer.shared.newsViewModel
    @State private var user: User?
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: GedSpacing.large) {
                    RecentAnnouncementSection(announcements: $newsViewModel.announcements)
                        .frame(maxHeight: geometry.size.height / 2.5)
                    newsSection
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, GedSpacing.medium)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Image(ImageResource.gedLogo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        
                        Text(getString(gedString: GedString.appName))
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    var newsSection: some View {
        VStack(alignment: .leading) {
            Text(getString(gedString: GedString.news))
                .font(.titleMedium)
                .padding(.horizontal)
        }
    }
}

struct RecentAnnouncementSection: View {
    @State private var selectedAnnouncement: Announcement? = nil
    @Binding private var announcements: [Announcement]
    
    init(announcements: Binding<[Announcement]>) {
        self._announcements = announcements
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(getString(gedString: GedString.recent_announcements))
                .font(.titleMedium)
                .padding(.horizontal)
            
            ScrollView {
                ForEach($announcements, id: \.id) { $announcement in
                    AnnouncementItemWithContent(announcement: $announcement, onClick: { selectedAnnouncement = announcement })
                        .background(
                            NavigationLink(
                                destination: AnnouncementDetailView(announcement: $announcement),
                                tag: announcement,
                                selection: $selectedAnnouncement
                            ) {
                                EmptyView()
                            }
                            .hidden()
                        )
                }
            }
        }
    }
}

#Preview {
    NewsView()
}
