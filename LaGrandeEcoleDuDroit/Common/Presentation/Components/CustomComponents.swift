import SwiftUI

struct TextItem: View {
    let image: Image
    let text: Text
    
    var body: some View {
        HStack(spacing: Dimens.mediumPadding) {
            image
            text
        }
    }
}

struct ClickableTextItem: View {
    let image: Image?
    let text: Text
    let onClick: () -> Void
    
    init(
        icon: Image? = nil,
        text: Text,
        onClick: @escaping () -> Void
    ) {
        self.image = icon
        self.text = text
        self.onClick = onClick
    }
    
    var body: some View {
        Button(
            action: onClick,
            label: {
                HStack(spacing: Dimens.mediumPadding) {
                    image
                    text
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        )
    }
}

struct PlainListItem<
    LeadingContent: View,
    TrailingContent: View,
    HeadlineContent: View
>: View {
    let leadingContent: LeadingContent
    let headlineContent: HeadlineContent
    let trailingContent: TrailingContent
    
    init(
        @ViewBuilder headlineContent: () -> HeadlineContent = { EmptyView() },
        @ViewBuilder leadingContent: () -> LeadingContent = { EmptyView() },
        @ViewBuilder trailingContent: () -> TrailingContent = { EmptyView() }
    ) {
        self.headlineContent = headlineContent()
        self.leadingContent = leadingContent()
        self.trailingContent = trailingContent()
    }
    
    var body: some View {
        HStack(alignment: .center) {
            leadingContent
                .padding(.trailing, Dimens.smallPadding)
            
            headlineContent
                .frame(maxWidth: .infinity, alignment: .leading)
            
            trailingContent
        }
        .padding(.vertical, Dimens.smallPadding)
        .padding(.horizontal)
    }
}

struct ListItem: View {
    let image: Image?
    let text: Text
    
    init(
        image: Image? = nil,
        text: Text
    ) {
        self.image = image
        self.text = text
    }
    
    var body: some View {
        HStack(spacing: Dimens.mediumPadding) {
            image
            text.frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
        }
    }
}

struct BottomSheetContainer<Content: View>: View {
    let fraction: CGFloat
    let content: Content
    
    init(
        fraction: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self.fraction = fraction
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 30) {
            content
        }
        .presentationDetents([.fraction(fraction)])
        .padding(.horizontal)
    }
}

struct CheckBox: View {
    let checked: Bool

    var body: some View {
        Image(systemName: checked ? "checkmark.square.fill" : "square")
            .foregroundColor(checked ? .gedPrimary : Color.secondary)
    }
}

struct SearchBar: UIViewRepresentable {
    let query: String
    let onQueryChange: (String) -> Void

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = stringResource(.search)
        searchBar.delegate = context.coordinator
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: Binding(get: { query }, set: onQueryChange))
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            self._text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }

        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(true, animated: true)
        }

        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(false, animated: true)
            searchBar.resignFirstResponder()
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true)
            searchBar.text = ""
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true)
        }
    }
}

#Preview {
    TextItem(
        image: Image(systemName: "key"),
        text: Text("Item with icon")
    )
    
    ClickableTextItem(
        icon: Image(systemName: "rectangle.portrait.and.arrow.right"),
        text: Text("Clickable text item"),
        onClick: {}
    )
    
    PlainListItem(
        headlineContent: { Text("List item") },
        leadingContent: { Image(systemName: "star") },
        trailingContent: { Image(systemName: "chevron.right") }
    )
    
    HStack {
        Text("Checkbox")
        CheckBox(
            checked: true
        )
    }
    
    SearchBar(
        query: "",
        onQueryChange: { _ in }
    )
}
