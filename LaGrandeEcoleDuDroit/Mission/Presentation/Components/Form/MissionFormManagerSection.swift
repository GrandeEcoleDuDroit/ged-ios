import SwiftUI

struct MissionFormManagerSection: View {
    let managers: [User]
    let onAddManagerClick: () -> Void
    let onRemoveManagerClick: (User) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            SectionTitle(title: stringResource(.managers))
                .padding(.horizontal)
            
            Spacer()
                .frame(height: Dimens.smallPadding)
            
            Button(action: onAddManagerClick) {
                AddManagerItem()
            }.buttonStyle(ClickStyle())
            
            VStack(spacing: .zero) {
                ForEach(managers) { manager in
                    MissionUserItem(
                        user: manager,
                        imageScale: 0.4,
                        trailingContent: {
                            if managers.count > 1 {
                                RemoveButton(action: { onRemoveManagerClick(manager) })
                            }
                        }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct AddManagerItem: View {
    var body: some View {
        PlainListItem(
            headlineContent: { Text(stringResource(.addManager)) },
            leadingContent: {
                Image(systemName: "person.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(10)
                    .background(.iconBackground)
                    .clipShape(.circle)
            }
        )
        .foregroundStyle(.onSurfaceVariant)
        .contentShape(.rect)
    }
}

#Preview {
    MissionFormManagerSection(
        managers: usersFixture,
        onAddManagerClick: {},
        onRemoveManagerClick: { _ in }
    )
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
