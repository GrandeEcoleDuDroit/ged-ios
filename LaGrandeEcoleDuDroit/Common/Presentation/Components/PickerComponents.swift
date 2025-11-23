import SwiftUI

struct MultiSelectionPicker<LeadingIcon: View>: View {
    let leadingIcon: (() -> LeadingIcon)?
    let text: String
    let items: [String]
    let seletctedItems: [String]
    let onItemSelected: (String) -> Void
    
    init(
        text: String,
        items: [String],
        seletctedItems: [String],
        onItemSelected: @escaping (String) -> Void
    ) where LeadingIcon == EmptyView {
        self.leadingIcon = nil
        self.text = text
        self.items = items
        self.seletctedItems = seletctedItems
        self.onItemSelected = onItemSelected
    }
    
    init(
        leadingIcon: @escaping () -> LeadingIcon,
        text: String,
        items: [String],
        seletctedItems: [String],
        onItemSelected: @escaping (String) -> Void
    ) {
        self.leadingIcon = leadingIcon
        self.text = text
        self.items = items
        self.seletctedItems = seletctedItems
        self.onItemSelected = onItemSelected
    }
    
    var body: some View {
        Menu(
            content: {
                ForEach(items, id: \.self) { item in
                    Button(
                        action: { onItemSelected(item) },
                        label: {
                            Label(
                                title: { Text(item) },
                                icon: { CheckBox(checked: seletctedItems.contains(item)) }
                            )
                        }
                    )
                }
            },
            label: {
                HStack(spacing: Dimens.mediumPadding) {
                    leadingIcon?().foregroundStyle(.onSurfaceVariant)
                    Text(text)
                }
                
                Spacer()
                
                Image(systemName: "chevron.up.chevron.down")
            }
        )
        .menuActionDismissBehavior(.disabled)
        .padding(.horizontal, Dimens.mediumPadding)
        .padding(.vertical, Dimens.mediumPadding)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(.outline, lineWidth: 1)
        )
    }
}

#Preview {
    MultiSelectionPicker(
        text: "Select item",
        items: ["1", "2", "3"],
        seletctedItems: ["1"],
        onItemSelected: { _ in }
    )
}
