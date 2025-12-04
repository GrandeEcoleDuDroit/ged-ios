struct UserReport {
    let userId: String
    let reportedUser: ReportedUser
    let reporterInfo: Reporter
    let reason: Reason
    
    struct ReportedUser {
        let fullName: String
        let email: String
    }
    
    struct Reporter {
        let fullName: String
        let email: String
    }
    
    enum Reason: String, Encodable, CaseIterable, CustomStringConvertible {
        case hackedAccount = "Hacked account"
        case pretendingToBeSomeoneElse = "Pretending to be someone else"
        case other = "Other"
        
        var description: String {
            rawValue
        }
    }
}
