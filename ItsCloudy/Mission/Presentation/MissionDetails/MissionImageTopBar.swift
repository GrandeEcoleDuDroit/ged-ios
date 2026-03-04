import SwiftUI

struct MissionImageTopBar: View {
    let onBackClick: () -> Void
    let onOptionsClick: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBackClick) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(.imageIconButtonContainer)
                    .clipShape(.circle)
            }
            
            Spacer()
            
            Button(action: onOptionsClick) {
                Image(systemName: "ellipsis")
                    .font(.title3)
                    .padding(.vertical, 17)
                    .padding(.horizontal, 10)
                    .background(.imageIconButtonContainer)
                    .clipShape(.circle)
            }
        }
        .padding(.horizontal, DimensResource.smallPadding)
        .padding(.vertical, DimensResource.smallPadding)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MissionImageTopBar(
        onBackClick: {},
        onOptionsClick: {}
    )
}
