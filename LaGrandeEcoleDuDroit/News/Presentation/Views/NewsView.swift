import SwiftUI

struct NewsView: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @State private var isActive: Bool = false
    @State private var isRefreshing: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: GedSpacing.medium) {
                RecentAnnouncementSection(
                    announcements: newsViewModel.announcements,
                    maxHeight: geometry.size.height / 2.5,
                    onRefresh: {
                        try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                        isRefreshing.toggle()
                    }
                )
                .id(isRefreshing)
                .frame(
                    minHeight: geometry.size.height / 8,
                    idealHeight: geometry.size.height / 8,
                    alignment: .top
                )
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
                    
                    Text(getString(.appName))
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if newsViewModel.currentUser?.isMember == true {
                    Button(
                        action: { isActive = true },
                        label: { Image(systemName: "plus") }
                    )
                    .navigationDestination(isPresented: $isActive) {
                        CreateAnnouncementView().environmentObject(newsViewModel)
                    }
                }
            }
        }
        .onAppear {
            tabBarVisibility.show = true
        }
    }
}

var newsSection: some View {
    VStack(alignment: .leading) {
        Text(getString(.news))
            .font(.titleMedium)
            .padding(.horizontal)
    }
}

struct RecentAnnouncementSection: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @State private var selectedAnnouncement: Announcement? = nil
    private var announcements: [Announcement]
    private var onRefresh: () async -> Void
    private let maxHeight: CGFloat
    
    init(
        announcements: [Announcement],
        maxHeight: CGFloat,
        onRefresh: @escaping () async -> Void
    ) {
        self.announcements = announcements
        self.maxHeight = maxHeight
        self.onRefresh = onRefresh
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(getString(.recentAnnouncements))
                .font(.titleMedium)
                .padding(.horizontal)
            
            if announcements.isEmpty {
                Text(getString(.noAnnouncement))
                    .font(.bodyLarge)
                    .foregroundColor(Color(UIColor.lightGray))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .top)
            } else {
                ScrollView {
                    ForEach(announcements) { announcement in
                        NavigationLink(value: announcement) {
                            GetAnnouncementItem(announcement: announcement)
                        }
                    }
                }
                .navigationDestination(for: Announcement.self, destination: { announcement in
                    AnnouncementDetailView(announcement: announcement)
                        .environmentObject(newsViewModel)
                })
                .frame(maxHeight: maxHeight)
                .fixedSize(horizontal: false, vertical: true)
                .refreshable {
                    await onRefresh()
                }
            }
        }
    }
}

struct GetAnnouncementItem: View {
    private var announcement: Announcement
    
    init(announcement: Announcement) {
        self.announcement = announcement
    }
    
    var body: some View {
        if case .loading = announcement.state {
            LoadingAnnouncementItemWithContent(announcement: announcement)
        }
        else if case .error = announcement.state {
            ErrorAnnouncementItemWithContent(announcement: announcement)
        } else {
            AnnouncementItemWithContent(announcement: announcement)
        }
    }
}


#Preview {
    NavigationStack {
        NewsView()
            .environmentObject(DependencyContainer.shared.mockNewsViewModel)
    }
}
