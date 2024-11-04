import SwiftUI

struct NewsView: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @State private var user: User?
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Voici l'user : \(newsViewModel.user?.fullName ?? "No value")")
            }
            .navigationTitle(getString(gedString: GedString.appName))
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            newsViewModel.fetchUser()
        }
    }
}

#Preview {
    NewsView()
}
