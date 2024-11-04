import SwiftUI

struct NewsView: View {
    private let imageWidth = UIScreen.main.bounds.width * 0.1
    private let imageHeight = UIScreen.main.bounds.height * 0.1
    
    var body: some View {
        NavigationView {
            HStack {
                RecentAnnouncementSection()
            }
            .navigationTitle(getString(gedString: GedString.appName))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(.gedLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageWidth, height: imageHeight)
                }
            }
        }.navigationBarBackButtonHidden()
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
