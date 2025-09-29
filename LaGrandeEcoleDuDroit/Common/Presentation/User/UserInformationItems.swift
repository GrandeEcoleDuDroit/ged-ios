import SwiftUI

struct UserInformationItems: View {
    let user: User
    
    private let values: [InformationItemValue]
    
    init(user: User) {
        self.user = user
        values = [
            InformationItemValue(label: getString(.lastName), value: user.lastName),
            InformationItemValue(label: getString(.firstName), value: user.firstName),
            InformationItemValue(label: getString(.email), value: user.email),
            InformationItemValue(label: getString(.schoolLevel), value: user.schoolLevel.rawValue)
        ]
    }
    
    var body: some View {
        VStack(spacing: GedSpacing.medium) {
            ForEach(values, id: \.label) { item in
                InformationItem(
                    title: item.label,
                    value: item.value
                )
            }
            
            if user.isMember {
               MemberField()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct MemberField: View {
    var body: some View {
        HStack {
            Text(getString(.member))
                .font(.callout)
                .bold()
                .foregroundColor(.gedPrimary)

            Image(systemName: "star.fill")
                .foregroundStyle(.gold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct InformationItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.callout)
                .bold()
                .foregroundColor(.gedPrimary)
            
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct InformationItemValue {
    let label: String
    let value: String
}

#Preview {
    UserInformationItems(user: userFixture).padding()
}
