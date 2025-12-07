import SwiftUI

struct MissionDetailsTopBar: View {
    let title: String
    let imageTopBar: Bool
    let onBackClick: () -> Void
    let onOptionsClick: () -> Void
    
    var body: some View {
        if imageTopBar {
            ImageTopBar(
                onBackClick: onBackClick,
                onOptionsClick: onOptionsClick
            )
        } else {
            TextTopBar(
                title: title,
                onBackClick: onBackClick,
                onOptionsClick: onOptionsClick
            )
        }
    }
}

private struct ImageTopBar: View {
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
                    .background(.imageIconButtonBackground)
                    .clipShape(.circle)
            }
            
            Spacer()
            
            Button(action: onOptionsClick) {
                Image(systemName: "ellipsis")
                    .font(.title3)
                    .padding(.vertical, 17)
                    .padding(.horizontal, 10)
                    .background(.imageIconButtonBackground)
                    .clipShape(.circle)
            }
        }
        .padding(.horizontal, Dimens.smallPadding)
        .padding(.vertical, Dimens.smallPadding)
        .frame(maxWidth: .infinity)
    }
}

private struct TextTopBar: View {
    let title: String
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
            }
                
            Text(title)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.headline)
                
            OptionsButton(action: onOptionsClick)
                .font(.title3)
                .padding(.vertical, 17)
                .padding(.horizontal, 10)
        }
        .padding(.horizontal, Dimens.smallPadding)
        .padding(.vertical, Dimens.smallPadding)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    MissionDetailsTopBar(
        title: "Mission",
        imageTopBar: true,
        onBackClick: {},
        onOptionsClick: {}
    )
}
