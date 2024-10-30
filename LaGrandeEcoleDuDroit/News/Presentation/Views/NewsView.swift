import SwiftUI

struct NewsView: View {
    var body: some View {
        NavigationView {
            HStack {
                
            }
            .navigationTitle(getString(gedString: GedString.appName))
            .navigationBarTitleDisplayMode(.inline)
        }.navigationBarBackButtonHidden()
    }
}

#Preview {
    NewsView()
}
