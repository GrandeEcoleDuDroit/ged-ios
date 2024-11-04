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

#Preview {
    NewsView()
}
