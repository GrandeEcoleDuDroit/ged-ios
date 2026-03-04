import SwiftUI

struct AccountDestination: View {
    let onDeleteAccountClick: () -> Void
    
    var body: some View {
        AccountView(onDeleteAccountClick: onDeleteAccountClick)
    }
}

private struct AccountView: View {
    let onDeleteAccountClick: () -> Void
        
    var body: some View {
        List {
            NavigationListItem(
                text: stringResource(.deleteAccount),
                onClick: onDeleteAccountClick
            )
        }
        .navigationTitle(stringResource(.account))
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    NavigationStack {
        AccountView(onDeleteAccountClick: {})
            .background(.profileSectionBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
