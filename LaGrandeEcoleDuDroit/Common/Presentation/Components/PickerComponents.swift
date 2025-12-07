import SwiftUI

struct MultiSelectionPicker: View {
    let text: String
    let items: [String]
    let leadingIcon: Image?
    let seletctedItems: [String]
    let onItemSelected: (String) -> Void
    var supportingText: String? = nil
    
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
        onItemSelected: @escaping (String) -> Void,
        supportingText: String? = nil
    ) {
        self.text = text
        self.items = items
        self.leadingIcon = leadingIcon
        self.seletctedItems = seletctedItems
        self.onItemSelected = onItemSelected
        self.supportingText = supportingText
    }
    
    var body: some View {
        VStack(alignment: .leading) {
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
                            .scaledToFit()
                            .frame(width: Dimens.inputIconSize, height: Dimens.inputIconSize)
                            .foregroundStyle(.onSurfaceVariant)
                        
                        Text(text)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up.chevron.down")
                }
            )
            .outlined()
            .menuActionDismissBehavior(.disabled)
            
            if let supportingText {
                Text(supportingText)
                    .font(.footnote)
                    .foregroundStyle(.informationText)
                    .padding(.leading, Dimens.mediumPadding)
                    .multilineTextAlignment(.leading)
            }
        }
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
