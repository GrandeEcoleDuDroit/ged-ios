import SwiftUI

struct SectionTitle: View {
    let title: String
    
    var body: some View {
        Text(title).font(.titleMedium)
    }
}

#Preview {
    SectionTitle(title: "Section title")
}
