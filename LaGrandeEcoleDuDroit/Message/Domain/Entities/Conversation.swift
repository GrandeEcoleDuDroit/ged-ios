struct Conversation: Hashable {
    var id: String
    var interlocutor: User
    var message: Message
    var isActive: Bool
    
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id
    }
    
    func copy(
        id: String? = nil,
        interlocutor: User? = nil,
        message: Message? = nil,
        isActive: Bool? = nil
    ) -> Conversation {
        Conversation(
            id: id ?? self.id,
            interlocutor: interlocutor ?? self.interlocutor,
            message: message ?? self.message,
            isActive: isActive ?? self.isActive
        )
    }
}
