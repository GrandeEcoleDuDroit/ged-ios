import SwiftUI

struct NewsDestination: View {
    let onAnnouncementClick: (String) -> Void
    let onCreateAnnouncementClick: () -> Void
    
    @StateObject private var viewModel = NewsInjection.shared.resolve(NewsViewModel.self)
    @State private var isRefreshing: Bool = false
    
    var body: some View {
        NewsView(
            user: viewModel.uiState.user,
            announcements: viewModel.uiState.announcements,
            refreshing: viewModel.uiState.refreshing,
            onRefreshAnnouncement: viewModel.refreshAnnouncements,
            onAnnouncementClick: onAnnouncementClick,
            onCreateAnnouncementClick: onCreateAnnouncementClick,
            onResendAnnouncementClick: viewModel.resendAnnouncement,
            onDeleteAnnouncementClick: viewModel.deleteAnnouncement
        )
    }
}

private struct NewsView: View {
    let user: User?
    let announcements: [Announcement]?
    let refreshing: Bool
    let onRefreshAnnouncement: () async -> Void
    let onAnnouncementClick: (String) -> Void
    let onCreateAnnouncementClick: () -> Void
    let onResendAnnouncementClick: (Announcement) -> Void
    let onDeleteAnnouncementClick: (Announcement) -> Void
    
    @State private var showBottomSheet: Bool = false
    @State private var showDeleteBottomSheet: Bool = false
    @State private var showDeleteAnnouncementAlert: Bool = false
    @State private var selectedAnnouncement: Announcement?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: GedSpacing.medium) {
                if let announcements = announcements {
                    RecentAnnouncementSection(
                        announcements: announcements,
                        onAnnouncementClick: onAnnouncementClick,
                        onUncreatedAnnouncementClick: {
                            selectedAnnouncement = $0
                            showBottomSheet = true
                        },
                    )
                    .id(refreshing)
                    .frame(
                        minHeight: geometry.size.height / 8,
                        maxHeight: geometry.size.height / 2.5,
                        alignment: .top
                    )
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .refreshable { await onRefreshAnnouncement() }
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
                        .fontWeight(.semibold)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                if user?.isMember ?? false {
                    Button(
                        action: onCreateAnnouncementClick,
                        label: { Image(systemName: "plus") }
                    )
                }
            }
        }
        .sheet(isPresented: $showBottomSheet) {
            BottomSheetContainer(fraction: 0.16) {
                ClickableItemWithIcon(
                    icon: Image(systemName: "paperplane"),
                    text: Text(getString(.resend))
                ) {
                    showBottomSheet = false
                    if let announcement = selectedAnnouncement {
                        onResendAnnouncementClick(announcement)
                    }
                }
                                
                ClickableItemWithIcon(
                    icon: Image(systemName: "trash"),
                    text: Text(getString(.delete))
                ) {
                    showBottomSheet = false
                    showDeleteAnnouncementAlert = true
                }
                .foregroundColor(.error)
            }
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
                    onDeleteAnnouncementClick(announcement)
                }
                showDeleteAnnouncementAlert = false
            }
        }
    }
}

struct RecentAnnouncementSection: View {
    let announcements: [Announcement]
    let onAnnouncementClick: (String) -> Void
    let onUncreatedAnnouncementClick: (Announcement) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(getString(.recentAnnouncements))
                .font(.titleMedium)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            ScrollView {
                if announcements.isEmpty {
                    Text(getString(.noAnnouncement))
                        .foregroundColor(Color(UIColor.lightGray))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .top)
                } else {
                    ForEach(announcements) { announcement in
                        ShortAnnouncementItem(announcement: announcement) {
                            if announcement.state == .published {
                                onAnnouncementClick(announcement.id)
                            } else {
                                onUncreatedAnnouncementClick(announcement)
                            }
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}


#Preview {
   NavigationStack {
       NewsView(
        user: userFixture,
        announcements: announcementsFixture,
        refreshing: false,
        onRefreshAnnouncement: {},
        onAnnouncementClick: {_ in },
        onCreateAnnouncementClick: {},
        onResendAnnouncementClick: {_ in },
        onDeleteAnnouncementClick: {_ in }
       )
   }
}
