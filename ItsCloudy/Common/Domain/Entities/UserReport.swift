struct UserReport {
    let userId: String
    let reportedUser: ReportedUser
    let reporterInfo: Reporter
    let reason: String
    
    struct ReportedUser {
        let fullName: String
        let email: String
    }
    
    struct Reporter {
        let fullName: String
        let email: String
    }
    
    enum Reason: Encodable, CaseIterable, CustomStringConvertible {
        case hackedAccount
        case pretendingToBeSomeoneElse
        
        var description: String {
            switch self {
                case .hackedAccount: stringResource(.hackedAccount)
                case .pretendingToBeSomeoneElse: stringResource(.pretendingToBeSomeoneElse)
            }
        }
    }
}
