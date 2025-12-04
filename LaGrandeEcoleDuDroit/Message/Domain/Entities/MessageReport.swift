struct MessageReport {
    let conversationId: String
    let messageId: String
    let recipient: Recipient
    let reason: Reason
    
    struct Recipient {
        let fullName: String
        let email: String
    }
    
    enum Reason: String, CaseIterable, CustomStringConvertible {
        case nudityOrSexualContent = "Nudity or sexual content"
        case hateSpeechOrSymbols = "Hate speech or symbols"
        case spam = "Spam"
        case bulliingOrHarassment = "Bullying or harassment"
        case illegalContent = "Illegal content"
        case scamOrFraud = "Scam or fraud"
        case other = "Other"
        
        var description: String {
            rawValue
        }
    }
}
