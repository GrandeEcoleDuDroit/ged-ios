import SwiftUI

struct NewsView: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @State private var isActive: Bool = false
    @State private var isRefreshing: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: GedSpacing.medium) {
                RecentAnnouncementSection(
                    announcements: $newsViewModel.announcements,
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
                    NavigationLink(
                        destination: CreateAnnouncementView().environmentObject(newsViewModel),
                        isActive: $isActive
                    ) {
                        Button(
                            action: { isActive = true },
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
        Text(getString(.news))
            .font(.titleMedium)
            .padding(.horizontal)
    }
}

struct RecentAnnouncementSection: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @State private var selectedAnnouncement: Announcement? = nil
    @Binding private var announcements: [Announcement]
    @State private var contentHeight: CGFloat = .zero
    private var onRefresh: () async -> Void
    private let maxHeight: CGFloat
    
    init(
        announcements: Binding<[Announcement]>,
        maxHeight: CGFloat,
        onRefresh: @escaping () async -> Void
    ) {
        self._announcements = announcements
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
                    ForEach($announcements, id: \.id) { $announcement in
                        GetAnnouncementItem(
                            announcement: announcement,
                            onClick: { selectedAnnouncement = announcement }
                        )
                        .background(
                            NavigationLink(
                                destination: AnnouncementDetailView(announcement: $announcement)
                                    .environmentObject(newsViewModel),
                                tag: announcement,
                                selection: $selectedAnnouncement,
                                label: { EmptyView() }
                            )
                            .hidden()
                        )
                        .overlay(
                            GeometryReader { geo in
                                Color.clear.onAppear {
                                    contentHeight = geo.size.height
                                }
                            }
                        )
                    }
                }
                .frame(maxHeight: min(maxHeight, contentHeight * CGFloat(announcements.count)))
                .refreshable {
                    await onRefresh()
                }
            }
        }
    }
}

struct GetAnnouncementItem: View {
    private var announcement: Announcement
    private let onClick: () -> Void
    
    init(announcement: Announcement, onClick: @escaping () -> Void) {
        self.announcement = announcement
        self.onClick = onClick
    }
    
    var body: some View {
        if case .loading = announcement.state {
            LoadingAnnouncementItemWithContent(
                announcement: announcement,
                onClick: onClick
            )
        }
        else if case .error = announcement.state {
            ErrorAnnouncementItemWithContent(
                announcement: announcement,
                onClick: onClick
            )
        } else {
            AnnouncementItemWithContent(
                announcement: announcement,
                onClick: onClick
            )
        }
    }
}


#Preview {
    NavigationView {
        NewsView()
            .environmentObject(DependencyContainer.shared.mockNewsViewModel)
    }
}
