struct AnnouncementReport: Encodable {
    let announcementId: String
    let authorInfo: UserInfo
    let userInfo: UserInfo
    let reason: Reason
    
    struct UserInfo: Encodable {
        let fullName: String
        let email: String
    }
    
    enum Reason: String, Encodable, CaseIterable, CustomStringConvertible {
        case sellingPromotingInappropriateContent = "Selling or promoting inappropriate content"
        case violentHatefulContent = "Violent or hateful content"
        case spamScam = "Spam or scam"
        case falseInformation = "False information"
        case intellectualPropertyViolation = "Intellectual property violation"
        case other = "Other"
        
        var description: String {
            rawValue
        }
    }
}
