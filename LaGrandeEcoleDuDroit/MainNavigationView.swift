import SwiftUI

struct MainNavigationView: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    
    var body: some View {
        TabView {
            NavigationView {
                NewsView()
                    .environmentObject(newsViewModel)
            }
            .tabItem {
                Label(getString(gedString: GedString.home), systemImage: "house.fill")
            }
            .tag(0)
        }
    }
}

#Preview {
    MainNavigationView()
        .environmentObject(DependencyContainer.shared.newsViewModel)
}
