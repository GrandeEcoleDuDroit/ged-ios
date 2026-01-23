import SwiftUI

struct FilterChip: View {
    let label: String
    let selected: Bool
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, DimensResource.chipPadding.horizontal)
                .frame(minHeight: DimensResource.chipMinHeight)
                .padding(DimensResource.chipPadding)
                .applyFilterChipStyle(selected)
        }
        .buttonStyle(.plain)
    }
}


private extension View {
    func applyFilterChipStyle(_ selected: Bool) -> some View {
        Group {
            if selected {
                self
                    .foregroundStyle(.onSecondaryContainer)
                    .background(Color.secondaryContainer)
                    .clipShape(ShapeDefaults.small)
            } else {
                self
                    .foregroundStyle(.onSurfaceVariant)
                    .overlay {
                        ShapeDefaults.small
                            .strokeBorder(.outline)
                    }
            }
        }
    }
}

#Preview {
    FilterChip(
        label: "Filter chip",
        selected: true,
        onClick: {}
    )
}
