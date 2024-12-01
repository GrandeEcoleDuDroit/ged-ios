import SwiftUI

struct MainNavigationView: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    
    var body: some View {
        TabView {
            NavigationView {
                NewsView()
                    .environmentObject(newsViewModel)
            }
            .tabItem { Label(getString(gedString: GedString.home), systemImage: "house.fill")}
            .tag(0)
            
            NavigationView {
                ProfileView()
                    .environmentObject(profileViewModel)
            }
            .tabItem { Label(getString(gedString: GedString.profile), systemImage: "person.fill") }
            .tag(1)
        }
    }
}

#Preview {
    MainNavigationView()
        .environmentObject(DependencyContainer.shared.newsViewModel)
        .environmentObject(DependencyContainer.shared.profileViewModel)
}
