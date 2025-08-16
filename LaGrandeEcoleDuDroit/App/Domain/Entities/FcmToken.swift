struct FcmToken: Codable {
    let userId: String?
    let value: String
    
    func with(
        userId: String? = nil,
        value: String? = nil
    ) -> FcmToken {
        FcmToken(
            userId: userId ?? self.userId,
            value: value ?? self.value
        )
    }
}
