import SwiftUI

struct SectionTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
    }
}

#Preview {
    SectionTitle(title: "Section title")
        .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
