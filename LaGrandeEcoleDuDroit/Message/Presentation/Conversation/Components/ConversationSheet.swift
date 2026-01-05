import SwiftUI

struct ConversationSheet: View {
    let conversationState: Conversation.ConversationState
    let onRecreateClick: () -> Void
    let onDeleteClick: () -> Void
    
    var body: some View {
        switch conversationState {
            case .error:
                ErrorConversationSheet(
                    onRecreateClick: onRecreateClick,
                    onDeleteClick: onDeleteClick
                )
                
            default: DefaultAnnouncementSheet(onDeleteClick: onDeleteClick)
        }
    }
}

private struct DefaultAnnouncementSheet: View {
    let onDeleteClick: () -> Void
    
    var body: some View {
        SheetContainer(fraction: Dimens.sheetFraction(itemCount: 1)) {
            SheetItem(
                icon: Image(systemName: "trash"),
                text: stringResource(.delete),
                onClick: onDeleteClick
            )
            .foregroundColor(.red)
        }
    }
}

private struct ErrorConversationSheet: View {
    let onRecreateClick: () -> Void
    let onDeleteClick: () -> Void
    
    var body: some View {
        SheetContainer(fraction: Dimens.sheetFraction(itemCount: 2)) {
            SheetItem(
                icon: Image(systemName: "arrow.clockwise"),
                text: stringResource(.retry),
                onClick: onRecreateClick
            )
            
            SheetItem(
                icon: Image(systemName: "trash"),
                text: stringResource(.delete),
                onClick: onDeleteClick
            )
            .foregroundColor(.red)
        }
    }
}

#Preview {
    ConversationSheet(
        conversationState: conversationFixture.state,
        onRecreateClick: {},
        onDeleteClick: {}
    )
}

