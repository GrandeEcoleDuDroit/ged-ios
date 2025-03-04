import SwiftUI

struct NewsView: View {
    @StateObject private var newsViewModel = NewsInjection.shared.resolve(NewsViewModel.self)
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var isRefreshing: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: GedSpacing.medium) {
                RecentAnnouncementSection(
                    announcements: newsViewModel.announcements,
                    maxHeight: geometry.size.height / 2.5,
                    onRefresh: {
                        Task {
                            isRefreshing = true
                            await newsViewModel.refreshAnnouncements()
                            isRefreshing = false
                        }
                    }
                )
                .id(isRefreshing)
                .frame(
                    minHeight: geometry.size.height / 8,
                    idealHeight: geometry.size.height / 8,
                    alignment: .top
                )
                .environmentObject(newsViewModel)
                .environmentObject(navigationCoordinator)
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
                        action: {
                            navigationCoordinator.push(NewsScreen.createAnnouncement)
                        },
                        label: { Image(systemName: "plus") }
                    )
                }
            }
        }
        .onAppear {
            tabBarVisibility.show = true
        }
    }
}

struct RecentAnnouncementSection: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var showSheet: Bool = false
    @State private var showDeleteSheet: Bool = false
    @State private var showDeleteAnnouncementAlert: Bool = false
    @State private var selectedAnnouncement: Announcement?
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
            
            ScrollView {
                if announcements.isEmpty {
                    Text(getString(.noAnnouncement))
                        .font(.bodyLarge)
                        .foregroundColor(Color(UIColor.lightGray))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .top)
                } else {
                    ForEach(announcements) { announcement in
                        if case .sending = announcement.state {
                            SendingAnnouncementItem(announcement: announcement) {
                                selectedAnnouncement = announcement
                                if announcement.date.timeIntervalSinceNow < -120 {
                                    showSheet = true
                                } else {
                                    showDeleteSheet = true
                                }
                            }
                        }
                        else if case .error = announcement.state {
                            ErrorAnnouncementItem(announcement: announcement) {
                                selectedAnnouncement = announcement
                                showSheet = true
                            }
                        } else {
                            AnnouncementItem(announcement: announcement) {
                                navigationCoordinator.push(NewsScreen.readAnnouncement(announcement))
                            }
                        }
                    }
                    .frame(maxHeight: maxHeight)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }.refreshable { await onRefresh() }
        }
        .sheet(isPresented: $showSheet) {
            VStack {
                ClickableItemWithIcon(
                    icon: Image(systemName: "paperplane"),
                    text: Text(getString(.resend))
                ) {
                    showSheet = false
                    if let announcement = selectedAnnouncement {
                        newsViewModel.resendAnnouncement(announcement: announcement)
                    }
                }
                
                ClickableItemWithIcon(
                    icon: Image(systemName: "trash"),
                    text: Text(getString(.delete))
                ) {
                    showSheet = false
                    showDeleteAnnouncementAlert = true
                }
                .foregroundColor(.error)
            }
            .presentationDetents([.fraction(0.18)])
        }
        .sheet(isPresented: $showDeleteSheet) {
            VStack {
                ClickableItemWithIcon(
                    icon: Image(systemName: "trash"),
                    text: Text(getString(.delete))
                ) {
                    showSheet = false
                    showDeleteAnnouncementAlert = true
                }
                .foregroundColor(.error)
            }
            .presentationDetents([.fraction(0.2)])
        }
        .alert(
            getString(.deleteAnnouncementAlertTitle),
            isPresented: $showDeleteAnnouncementAlert
        ) {
            Button(getString(.cancel), role: .cancel) {
                showDeleteAnnouncementAlert = false
            }
            
            Button(getString(.delete), role: .destructive) {
                if let announcement = selectedAnnouncement {
                    newsViewModel.deleteAnnouncement(announcement: announcement)
                }
                showDeleteAnnouncementAlert = false
            }
        }
    }
}


#Preview {
   NavigationStack {
       NewsView()
           .environmentObject(TabBarVisibility())
           .environmentObject(NavigationCoordinator())
   }
}
