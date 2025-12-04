import SwiftUI

struct MultiSelectionPicker: View {
    let text: String
    let items: [String]
    let leadingIcon: Image?
    let seletctedItems: [String]
    let onItemSelected: (String) -> Void
    
    init(
        text: String,
        items: [String],
        seletctedItems: [String],
        onItemSelected: @escaping (String) -> Void
    ) {
        self.text = text
        self.items = items
        self.leadingIcon = nil
        self.seletctedItems = seletctedItems
        self.onItemSelected = onItemSelected
    }
    
    init(
        text: String,
        items: [String],
        leadingIcon: Image,
        seletctedItems: [String],
        onItemSelected: @escaping (String) -> Void
    ) {
        self.text = text
        self.items = items
        self.leadingIcon = leadingIcon
        self.seletctedItems = seletctedItems
        self.onItemSelected = onItemSelected
    }
    
    var body: some View {
        Menu(
            content: {
                ForEach(items, id: \.self) { item in
                    Button(action: { onItemSelected(item) }) {
                        Label(
                            title: { Text(item) },
                            icon: { CheckBox(checked: seletctedItems.contains(item)) }
                        )
                    }
                }
            },
            label: {
                HStack(alignment: .center, spacing: Dimens.leadingIconSpacing) {
                    leadingIcon?
                        .resizable()
                        .scaledToFill()
                        .frame(width: Dimens.inputIconSize, height: Dimens.inputIconSize)
                        .foregroundStyle(.onSurfaceVariant)
                    
                    Text(text)
                }
                
                Spacer()
                
                Image(systemName: "chevron.up.chevron.down")
            }
        )
        .menuActionDismissBehavior(.disabled)
        .outlined()
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
