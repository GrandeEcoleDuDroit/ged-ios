import SwiftUI

struct NewsView: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @State private var showBottomSheet: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: GedSpacing.large) {
                RecentAnnouncementSection(
                    announcements: $newsViewModel.announcements,
                    currentUser: newsViewModel.user!
                )
                .frame(maxHeight: geometry.size.height / 2.5)
                .environmentObject(newsViewModel)
                
                newsSection
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, GedSpacing.medium)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Image(ImageResource.gedLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                    
                    Text(getString(gedString: GedString.appName))
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if newsViewModel.user?.isMember == true {
                    Button(
                        action: { showBottomSheet = true },
                        label: {
                            Image(systemName: "plus")
                        }
                    ).sheet(isPresented: $showBottomSheet) {
                        CreateAnnouncementView()
                    }
                }
            }
        }
    }
}

var newsSection: some View {
    VStack(alignment: .leading) {
        Text(getString(gedString: GedString.news))
            .font(.titleMedium)
            .padding(.horizontal)
    }
}

struct RecentAnnouncementSection: View {
    @State private var selectedAnnouncement: Announcement? = nil
    @Binding private var announcements: [Announcement]
    @EnvironmentObject private var newsViewModel: NewsViewModel
    private var currentUser: User
    
    init(announcements: Binding<[Announcement]>, currentUser: User) {
        self._announcements = announcements
        self.currentUser = currentUser
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(getString(gedString: GedString.recent_announcements))
                .font(.titleMedium)
                .padding(.horizontal)
            
            if announcements.isEmpty {
                Text(getString(gedString: GedString.no_announcement))
                    .font(.bodyLarge)
                    .foregroundColor(Color(UIColor.lightGray))
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            } else {
                ScrollView {
                    ForEach($announcements, id: \.id) { $announcement in
                        AnnouncementItemWithContent(
                            announcement: $announcement,
                            onClick: { selectedAnnouncement = announcement }
                        )
                        .background(
                            NavigationLink(
                                destination: AnnouncementDetailView(
                                    announcement: $announcement,
                                    currentUser: currentUser
                                ).environmentObject(newsViewModel),
                                tag: announcement,
                                selection: $selectedAnnouncement,
                                label: { EmptyView() }
                            )
                            .hidden()
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        NewsView()
            .environmentObject(DependencyContainer.shared.newsViewModel)
    }
}
