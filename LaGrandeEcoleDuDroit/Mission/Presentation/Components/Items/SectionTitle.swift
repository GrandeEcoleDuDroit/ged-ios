import SwiftUI

struct SectionTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
    }
}

#Preview {
    SectionTitle(title: "Section title")
        .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
