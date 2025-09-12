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
            MenuItem(
                title: getString(.deleteAccount),
                onClick: onDeleteAccountClick
            )
        }
        .navigationTitle(getString(.account))
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .scrollContentBackground(.hidden)
        .background(.listBackground)
    }
}

#Preview {
    NavigationStack {
        AccountView(onDeleteAccountClick: {})
            .background(.listBackground)
    }
}
