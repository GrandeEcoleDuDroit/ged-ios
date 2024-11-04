import SwiftUI

struct NewsView: View {
    @StateObject private var newsViewModel: NewsViewModel = DependencyContainer.shared.newsViewModel
    @State private var user: User?
    
    var body: some View {
        NavigationView {
            VStack {
                
            }
            .navigationTitle(getString(gedString: GedString.appName))
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationBarBackButtonHidden()
    }
}

struct RecentAnnouncementSection: View {
    var body: some View {
        ScrollView {
            ForEach(1...100, id: \.self) { number in
                Text("Nombre \(number)")
            }
        }
    }
}

#Preview {
    NewsView()
}
