import FirebaseFirestore

extension Query {
    func withOffsetTime(_ offsetTime: Timestamp?) -> Query {
        if let offsetTime = offsetTime {
            self.whereField(MessageField.timestamp, isGreaterThan: offsetTime)
        } else {
            self
        }
    }
}
