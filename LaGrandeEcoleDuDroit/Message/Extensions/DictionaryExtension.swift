extension Dictionary where Value == ConversationUI {
    func sortedByDate() -> [ConversationUI] {
        values.sorted {
            return if let lastMessage = $0.lastMessage, let lastMessage2 = $1.lastMessage {
                lastMessage.date > lastMessage2.date
            } else {
                $0.createdAt > $1.createdAt
            }
        }
    }
}

extension Dictionary where Value == Message {
    func sortedByDate() -> [Message] {
        values.sorted { $0.date < $1.date }
    }
}
