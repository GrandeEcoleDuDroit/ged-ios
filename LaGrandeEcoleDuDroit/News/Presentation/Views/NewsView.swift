import SwiftUI

struct NewsView: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @State private var isPresented: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: GedSpacing.large) {
                RecentAnnouncementSection(announcements: $newsViewModel.announcements)
                    .frame(maxHeight: geometry.size.height / 2.5)
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
                if true {
                    NavigationLink(destination: CreateAnnouncementView(), isActive: $isPresented) {
                        Button(
                            action: { isPresented = true },
                            label: { Image(systemName: "plus") }
                        )
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
    
    init(announcements: Binding<[Announcement]>) {
        self._announcements = announcements
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            } else {
                ScrollView {
                    ForEach($announcements, id: \.id) { $announcement in
                        AnnouncementItemWithContent(announcement: $announcement, onClick: { selectedAnnouncement = announcement })
                            .background(
                                NavigationLink(
                                    destination: AnnouncementDetailView(announcement: $announcement),
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
