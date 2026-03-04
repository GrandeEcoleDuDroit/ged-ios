import Foundation

let conversationFixture = Conversation(
    id: "1",
    interlocutor: usersFixture[1],
    createdAt: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
    state: .created,
    effectiveFrom: nil
)

let conversationsFixture = [
    conversationFixture,
    conversationFixture.copy { $0.id = "2" },
    conversationFixture.copy { $0.id = "3" },
    conversationFixture.copy { $0.id = "4" },
    conversationFixture.copy { $0.id = "5" }
]

let conversationUiFixture = ConversationUi(
    id: "1",
    interlocutor: userFixture2,
    lastMessage: messageFixture,
    createdAt: Date(),
    state: .created
)

let conversationsUiFixture = [
    conversationUiFixture.copy {
        $0.lastMessage = messageFixture.copy { $0.seen = false }
    },
    conversationUiFixture.copy {
        $0.id = "2";
        $0.interlocutor = usersFixture[2];
        $0.lastMessage = messageFixture.copy {
            $0.senderId = usersFixture[2].id;
            $0.seen = false;
            $0.date = Calendar.current.date(byAdding: .minute, value: -5, to: Date())!;
            $0.content = "Bonne vacance !"
        }
    },
    conversationUiFixture.copy {
        $0.id = "3";
        $0.interlocutor = usersFixture[1];
        $0.lastMessage = messageFixture.copy {
            $0.seen = true;
            $0.date = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!;
            $0.content = "On s'y retrouve à 14h. 👍"
        }
    },
    conversationUiFixture.copy {
        $0.id = "4";
        $0.interlocutor = userFixture3;
        $0.lastMessage = messageFixture.copy {
            $0.seen = true;
            $0.date = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!;
            $0.content = "Le prof a oublié les devoirs 😂"
        }
    },
    conversationUiFixture.copy {
        $0.id = "5";
        $0.interlocutor = usersFixture[3];
        $0.lastMessage = messageFixture.copy {
            $0.seen = true;
            $0.date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!;
            $0.content = "Camomille + thé matcha 🍵"
        }
    },
    conversationUiFixture.copy {
        $0.id = "6";
        $0.interlocutor = usersFixture[5];
        $0.lastMessage = messageFixture.copy {
            $0.seen = true;
            $0.date = Calendar.current.date(byAdding: .month, value: -2, to: Date())!;
            $0.content = "Prochaine session demain matin à 9h."
        }
    },
]

let conversationMessageFixture = ConversationMessage(
    conversation: conversationFixture,
    lastMessage: messageFixture
)

let conversationMessagesFixture = conversationsUiFixture.map { conversationUi in
    ConversationMessage(
        conversation: conversationUi.toConversation(),
        lastMessage: conversationUi.lastMessage
    )
}
