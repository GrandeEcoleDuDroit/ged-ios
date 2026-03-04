import SwiftUI

struct MultiSelectionPicker: View {
    let text: String
    let placeholder: String
    let items: [String]
    let leadingIcon: Image?
    let seletctedItems: [String]
    let onItemSelected: (String) -> Void
    var supportingText: String? = nil
    
    init(
        text: String,
        placeholder: String,
        items: [String],
        seletctedItems: [String],
        onItemSelected: @escaping (String) -> Void
    ) {
        self.text = text
        self.placeholder = placeholder
        self.items = items
        self.leadingIcon = nil
        self.seletctedItems = seletctedItems
        self.onItemSelected = onItemSelected
    }
    
    init(
        text: String,
        placeholder: String,
        items: [String],
        leadingIcon: Image,
        seletctedItems: [String],
        onItemSelected: @escaping (String) -> Void,
        supportingText: String? = nil
    ) {
        self.text = text
        self.placeholder = placeholder
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
                    HStack(alignment: .center, spacing: DimensResource.leadingIconSpacing) {
                        leadingIcon?
                            .resizable()
                            .scaledToFit()
                            .frame(width: DimensResource.inputIconSize, height: DimensResource.inputIconSize)
                            .foregroundStyle(.onSurfaceVariant)
                        
                        if seletctedItems.isEmpty {
                            Text(placeholder).foregroundStyle(.onSurfaceVariant)
                        } else {
                            Text(text)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up.chevron.down")
                }
            )
            .outlined()
            .menuActionDismissBehavior(.disabled)
            
            if let supportingText {
                Text(supportingText)
                    .font(.caption)
                    .foregroundStyle(.informationText)
                    .padding(.leading, DimensResource.mediumPadding)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

#Preview {
    MultiSelectionPicker(
        text: "",
        placeholder: "Select item",
        items: ["1", "2", "3"],
        seletctedItems: [],
        onItemSelected: { _ in }
    ).padding(.horizontal)
}
