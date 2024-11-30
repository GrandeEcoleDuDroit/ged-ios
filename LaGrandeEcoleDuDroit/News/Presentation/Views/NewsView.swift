import SwiftUI

struct NewsView: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @State private var showBottomSheet: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: GedSpacing.large) {
                RecentAnnouncementSection(
                    announcements: $newsViewModel.announcements,
                    maxHeight: geometry.size.height / 2.5,
                    onRefresh: { try? await Task.sleep(nanoseconds: 3 * 1_000_000_000) }
                )
                .frame(
                    minHeight: geometry.size.height / 8,
                    idealHeight: geometry.size.height / 8,
                    alignment: .top
                )
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
                        label: { Image(systemName: "plus") }
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
    @State private var contentHeight: CGFloat = .zero
    private var onRefresh: () async -> Void
    private let maxHeight: CGFloat
    @State private var isRefreshing: Bool = false
    
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
            Text(getString(gedString: GedString.recent_announcements))
                .font(.titleMedium)
                .padding(.horizontal)
            
            if announcements.isEmpty {
                Text(getString(gedString: GedString.no_announcement))
                    .font(.bodyLarge)
                    .foregroundColor(Color(UIColor.lightGray))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .top)
            } else {
                ScrollView {
                    ForEach($announcements, id: \.id) { $announcement in
                        GetAnnouncementItem(
                            announcement: $announcement,
                            onClick: { selectedAnnouncement = announcement }
                        )
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(
                            NavigationLink(
                                destination: AnnouncementDetailView(announcement: $announcement),
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
                .frame(maxHeight: min(maxHeight, contentHeight * CGFloat(announcements.count) + 20))
                .refreshable(action: onRefresh)
            }
        }
    }
}

struct GetAnnouncementItem: View {
    @Binding private var announcement: Announcement
    private let onClick: () -> Void
    
    init(announcement: Binding<Announcement>, onClick: @escaping () -> Void) {
        self._announcement = announcement
        self.onClick = onClick
    }
    
    var body: some View {
        if case .loading = announcement.state {
            LoadingAnnouncementItemWithContent(
                announcement: $announcement,
                onClick: onClick
            )
        }
        else if case .error = announcement.state {
            ErrorAnnouncementItemWithContent(
                announcement: $announcement,
                onClick: onClick
            )
        } else {
            AnnouncementItemWithContent(
                announcement: $announcement,
                onClick: onClick
            )
        }
    }
}


#Preview {
    NavigationView {
        NewsView()
            .environmentObject(DependencyContainer.shared.newsViewModel)
    }
}
