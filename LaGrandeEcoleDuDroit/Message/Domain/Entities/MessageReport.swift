struct MessageReport {
    let conversationId: String
    let messageId: String
    let recipient: Recipient
    let reason: String
    
    struct Recipient {
        let fullName: String
        let email: String
    }
    
    enum Reason: String, CaseIterable, CustomStringConvertible {
        case nudityOrSexualContent
        case hateSpeechOrSymbols
        case spam
        case bulliingOrHarassment
        case illegalContent
        case scamOrFraud
        
        var description: String {
            switch self {
                case .nudityOrSexualContent: stringResource(.nudityOrSexualContent)
                case .hateSpeechOrSymbols: stringResource(.hateSpeechOrSymbols)
                case .spam: stringResource(.spam)
                case .bulliingOrHarassment: stringResource(.bulliingOrHarassment)
                case .illegalContent: stringResource(.illegalContent)
                case .scamOrFraud: stringResource(.scamOrFraud)
            }
        }
    }
}
