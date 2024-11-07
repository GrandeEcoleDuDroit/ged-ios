import SwiftUI

struct NewsView: View {
    @StateObject private var newsViewModel: NewsViewModel =
DependencyContainer.shared.newsViewModel
    @State private var user: User?
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: GedSpacing.large) {
                    recentAnnouncementSection
                        .frame(maxHeight: geometry.size.height / 2.5)
                    newsSection
                }
            }
            .navigationTitle(getString(gedString: GedString.appName))
            .navigationBarTitleDisplayMode(.inline)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 10)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(ImageResource.gedLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    var recentAnnouncementSection: some View {
        VStack(alignment: .leading) {
            Text(getString(gedString: GedString.recent_announcements))
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)
            ScrollView {
                ForEach($newsViewModel.announcements, id: \.id) { $announcement in
                    RecentAnnouncement(announcement: $announcement)
                }
            }
        }
    }
    
    var newsSection: some View {
        VStack(alignment: .leading) {
            Text(getString(gedString: GedString.news))
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)
        }
    }
}

#Preview {
    NewsView()
}
