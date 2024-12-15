extension Dictionary where Value == ConversationUI {
    func sortedByDate() -> [ConversationUI] {
        return self.values.sorted {
            if let lastMessage = $0.lastMessage, let lastMessage2 = $1.lastMessage {
                return lastMessage.date > lastMessage2.date
            } else {
                return $0.createdAt > $1.createdAt
            }
        }
    }
}
