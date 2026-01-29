import SwiftUI

struct SheetContainer<Content: View>: View {
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
        VStack(spacing: DimensResource.sheetItemSpacing) {
            content
        }
        .presentationDetents([.fraction(fraction)])
        .padding(.horizontal)
    }
}

struct SheetItem: View {
    let icon: Image?
    let text: String
    let onClick: () -> Void
    
    init(
        icon: Image? = nil,
        text: String,
        onClick: @escaping () -> Void
    ) {
        self.icon = icon
        self.text = text
        self.onClick = onClick
    }
    
    var body: some View {
        Button(
            action: onClick,
            label: {
                Group {
                    if let icon {
                        TextIcon(icon: icon, text: text)
                    } else {
                        Text(text)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        )
    }
}

struct ReportSheet<T: CustomStringConvertible>: View {
    let items: [T]
    let onReportClick: (String) -> Void
    
    @State private var path: [ReportSheetDestination] = []
    @State private var fraction: CGFloat
    private let defaultFraction: CGFloat
    
    init(
        items: [T],
        onReportClick: @escaping (String) -> Void
    ) {
        self.items = items
        self.onReportClick = onReportClick
        self.defaultFraction = DimensResource.reportSheetFraction(itemCount: items.count)
        self.fraction = defaultFraction
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: DimensResource.sheetItemSpacing) {
                ForEach(items.indices, id: \.self) { index in
                    let reason = items[index].description
                    SheetItem(
                        text: reason,
                        onClick: { onReportClick(reason) }
                    )
                }
                
                SheetItem(
                    text: stringResource(.otherReportReason),
                    onClick: { path.append(.other) }
                )
            }
            .padding(.horizontal)
            .onAppear { fraction = defaultFraction }
            .navigationTitle(stringResource((.report)))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ReportSheetDestination.self) { destination in
                switch destination {
                    case .other:
                        EditableSheetContent(onSubmitClick: onReportClick)
                            .navigationTitle(stringResource((.otherReportReason)))
                            .navigationBarTitleDisplayMode(.inline)
                            .onAppear { fraction = max(defaultFraction, 0.35) }
                }
            }
        }
        .presentationDetents([.fraction(fraction)])
    }
}

private enum ReportSheetDestination: Hashable {
    case other
}

private struct EditableSheetContent: View {
    let onSubmitClick: (String) -> Void
    
    @State private var value: String = ""
    @FocusState private var focusState: SheetFocusField?
    private let maxTextLength: Int = 300
    
    private var submitEnabled: Bool {
        !value.isEmpty
    }
    
    var body: some View {
        TransparentTextFieldArea(
            stringResource(.otherReportSheetPlaceholder),
            text: $value,
            focusState: _focusState,
            field: .editableSheetContent
        )
        .onChange(of: value) {
            value = $0.take(maxTextLength)
        }
        .onAppear {
            focusState = .editableSheetContent
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .padding(.horizontal, DimensResource.smallMediumPadding)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: { onSubmitClick(value) }) {
                    if submitEnabled {
                        Text(stringResource(.submit))
                            .foregroundColor(.gedPrimary)
                    } else {
                        Text(stringResource(.submit))
                    }
                }
                .disabled(!submitEnabled)
            }
        }
    }
}

private enum SheetFocusField: Hashable {
    case editableSheetContent
}
