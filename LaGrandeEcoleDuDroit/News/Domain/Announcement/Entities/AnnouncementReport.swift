struct AnnouncementReport: Encodable {
    let announcementId: String
    let author: Author
    let reporter: Reporter
    let reason: String
    
    struct Author: Encodable {
        let fullName: String
        let email: String
    }
    
    struct Reporter: Encodable {
        let fullName: String
        let email: String
    }
    
    enum Reason: Encodable, CaseIterable, CustomStringConvertible {
        case sellingPromotingInappropriateContent
        case violentHatefulContent
        case spamScam
        case falseInformation
        case intellectualPropertyViolation
        
        var description: String {
            switch self {
                case .sellingPromotingInappropriateContent: stringResource(.sellingPromotingInappropriateContentReportReason)
                case .violentHatefulContent: stringResource(.violentHatefulContentReportReason)
                case .spamScam: stringResource(.spamScamReportReason)
                case .falseInformation: stringResource(.falseInformationReportReason)
                case .intellectualPropertyViolation: stringResource(.intellectualPropertyViolationReportReason)
            }
        }
    }
}
