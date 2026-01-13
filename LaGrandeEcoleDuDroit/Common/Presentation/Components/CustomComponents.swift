import SwiftUI

struct CheckBox: View {
    let checked: Bool

    var body: some View {
        Image(systemName: checked ? "checkmark.square.fill" : "square")
            .foregroundColor(checked ? .gedPrimary : Color.secondary)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        HStack {
            Text("Checkbox")
            CheckBox(
                checked: true
            )
        }
    }
    .frame(maxWidth: .infinity)
}
