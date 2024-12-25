import SwiftUI

struct SendMessageItem: View {
    @State var text: String
    @State var screenWidth: CGFloat
    
    init(text: String, screenWidth: CGFloat) {
        self.text = text
        self.screenWidth = screenWidth
    }
    
    var body: some View {
        ZStack {
            Text(text)
                .foregroundStyle(.white)
                .padding()
                .background(.gedPrimary)
                .clipShape(.rect(cornerRadius: 30))
                .frame(maxWidth: screenWidth / 1.5, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct ReceiveMessageItem: View {
    @State var text: String
    @State var screenWidth: CGFloat
    
    init(text: String, screenWidth: CGFloat) {
        self.text = text
        self.screenWidth = screenWidth
    }
    
    var body: some View {
        ZStack {
            Text(text)
                .foregroundStyle(.black)
                .padding()
                .background(.receiveMessageComponentBackground)
                .clipShape(.rect(cornerRadius: 30))
                .frame(maxWidth: screenWidth / 1.5, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ChatInputField: View {
    @Binding var text: String
    private var onSendClick: () -> Void
    private let maxCharacters = 1000
    
    init(text: Binding<String>, onSendClick: @escaping () -> Void) {
        self._text = text
        self.onSendClick = onSendClick
    }
    
    var body: some View {
        HStack(alignment: .center) {
            DynamicTextEditor(
                text: $text,
                placeholderText: Text(getString(.messagePlaceholder)),
                minHeight: 34,
                maxHeight: 200
            )
            .transparentScrolling()
            .padding(.leading)
            .limitText($text, to: maxCharacters)
            
            if !text.isBlank {
                Button(
                    action: onSendClick,
                    label: {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                )
                .padding(.horizontal, GedSpacing.medium)
                .padding(.vertical, 10)
                .background(.gedPrimary)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 20))
            }
        }
        .padding(.trailing, GedSpacing.small)
        .padding(.vertical, GedSpacing.small)
        .background(.receiveMessageComponentBackground)
        .clipShape(.rect(cornerRadius: 30))
    }
    
    var messagePlaceholder: Text {
        if #available(iOS 17.0, *) {
            Text(getString(.messagePlaceholder))
                .foregroundStyle(.gray)
        } else {
            Text(getString(.messagePlaceholder))
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    VStack {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: GedSpacing.medium) {
                    SendMessageItem(text: announcementFixture.content, screenWidth: geometry.size.width)
                    ReceiveMessageItem(text: announcementFixture.title!, screenWidth: geometry.size.width)
                }
            }
        }
        
        ChatInputField(text: .constant(""), onSendClick: {})
    }
    .padding(.horizontal)
}
