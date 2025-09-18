struct UserReport {
    let userId: String
    let userInfo: UserInfo
    let reporterInfo: UserInfo
    let reason: Reason
    
    struct UserInfo {
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
